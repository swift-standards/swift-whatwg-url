// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

public import Domain_Standard
public import RFC_791
public import RFC_5952

extension WHATWG_URL.URL {
    /// A host as defined by the WHATWG URL Standard
    ///
    /// A host is a domain, an IPv4 address, an IPv6 address, an opaque host, or an empty host.
    /// Typically a host serves as a network address, but it is sometimes used as an opaque identifier
    /// in URLs where a network address is not necessary.
    public enum Host: Hashable, Sendable {
        /// A domain (e.g., "example.com", with IDNA support)
        case domain(Domain_Standard.Domain)

        /// An IPv4 address (RFC 791)
        case ipv4(RFC_791.IPv4.Address)

        /// An IPv6 address (RFC 4291, serialized per RFC 5952)
        case ipv6(RFC_4291.IPv6.Address)

        /// An opaque host (non-special schemes)
        case opaque(String)

        /// An empty host (allowed for file: URLs)
        case empty
    }
}

// MARK: - Host Serialization

extension WHATWG_URL.URL.Host {
    /// Serializes a host to its string representation
    ///
    /// This is the authoritative implementation per WHATWG URL Standard Section 4.4.
    ///
    /// ## Serialization Rules
    ///
    /// - **Domain**: IDNA-encoded domain name (delegated to Domain Standard)
    /// - **IPv4**: RFC 791 dotted-decimal notation (delegated to RFC 791)
    /// - **IPv6**: RFC 5952 canonical text representation with brackets (delegated to RFC 5952)
    /// - **Opaque**: Percent-encoded host string (as-is)
    /// - **Empty**: Empty string
    ///
    /// ## Delegation Pattern
    ///
    /// This primitive delegates to RFC-defined serializations:
    /// - IPv4 → `String(address)` uses RFC 791
    /// - IPv6 → `String(address)` uses RFC 5952
    /// - Domain → `.name` property provides IDNA encoding
    ///
    /// The WHATWG-specific requirement (IPv6 brackets) is applied here.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Total function - always produces a valid String
    /// - **Injectivity**: Different hosts produce different strings (up to normalization)
    /// - **Determinism**: Same host always produces same string
    ///
    /// - Parameter host: The host to serialize
    /// - Returns: String representation of the host
    public static func serialize(_ host: Self) -> String {
        switch host {
        case .domain(let domain):
            // IDNA-encoded domain name
            return domain.name

        case .ipv4(let address):
            // RFC 791 dotted-decimal notation
            return String(address)

        case .ipv6(let address):
            // RFC 5952 canonical text representation
            // WHATWG URL requires IPv6 addresses to be enclosed in brackets
            return "[" + String(address) + "]"

        case .opaque(let host):
            // Opaque host string (percent-encoded)
            return host

        case .empty:
            // Empty host
            return ""
        }
    }
}
