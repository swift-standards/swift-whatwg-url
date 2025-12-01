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
public import INCITS_4_1986

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

// MARK: - Host.Context

extension WHATWG_URL.URL.Host {
    /// Context for parsing a host
    ///
    /// Per WHATWG URL Standard, host parsing behavior differs based on whether
    /// the URL has a "special" scheme (http, https, ftp, file, ws, wss).
    public struct Context: Sendable {
        /// Whether this host is for a special scheme URL
        ///
        /// Special schemes parse hosts as domains (with IDNA).
        /// Non-special schemes parse hosts as opaque strings.
        public let isSpecial: Bool

        public init(isSpecial: Bool) {
            self.isSpecial = isSpecial
        }

        /// Context for special scheme URLs (http, https, etc.)
        public static let special = Context(isSpecial: true)

        /// Context for non-special scheme URLs
        public static let nonSpecial = Context(isSpecial: false)
    }
}

// MARK: - UInt8.ASCII.Serializable

extension WHATWG_URL.URL.Host: UInt8.ASCII.Serializable {
    /// Serialize the host into an ASCII byte buffer
    ///
    /// Per WHATWG URL Standard Section 4.4: Host Serializing.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii host: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        switch host {
        case .domain(let domain):
            buffer.append(contentsOf: domain.name.utf8)

        case .ipv4(let address):
            RFC_791.IPv4.Address.serialize(ascii: address, into: &buffer)

        case .ipv6(let address):
            buffer.append(UInt8.ascii.leftSquareBracket)
            RFC_4291.IPv6.Address.serialize(ascii: address, into: &buffer)
            buffer.append(UInt8.ascii.rightSquareBracket)

        case .opaque(let host):
            buffer.append(contentsOf: host.utf8)

        case .empty:
            break
        }
    }

    /// Parse a host from ASCII bytes
    ///
    /// Per WHATWG URL Standard Section 4.4: Host Parsing.
    ///
    /// ## Parsing Rules
    ///
    /// 1. If input starts with `[`, parse as IPv6
    /// 2. If `isSpecial` context, try IPv4, then domain
    /// 3. Otherwise, parse as opaque host
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Context
    ) throws(Error) where Bytes.Element == UInt8 {
        let array = Array(bytes)

        // Empty host
        guard !array.isEmpty else {
            self = .empty
            return
        }

        // Check for IPv6 (starts with '[')
        if array.first == UInt8.ascii.leftSquareBracket {
            guard array.last == UInt8.ascii.rightSquareBracket else {
                throw .ipv6BracketMismatch
            }

            let ipv6Bytes = array.dropFirst().dropLast()

            do {
                let address = try RFC_4291.IPv6.Address(ascii: Array(ipv6Bytes))
                self = .ipv6(address)
            } catch {
                throw .invalidIPv6Address(String(decoding: array, as: UTF8.self))
            }
            return
        }

        let hostString = String(decoding: array, as: UTF8.self)

        // For special schemes: try IPv4, then domain
        if context.isSpecial {
            // Simple IPv4 detection: contains only digits and dots
            let isIPv4Candidate = hostString.allSatisfy { $0.isNumber || $0 == "." }

            if isIPv4Candidate {
                do {
                    let address = try RFC_791.IPv4.Address(hostString)
                    self = .ipv4(address)
                    return
                } catch {
                    // Not a valid IPv4, continue to domain
                }
            }

            // Try parsing as domain
            do {
                let domain = try Domain_Standard.Domain(hostString)
                self = .domain(domain)
            } catch {
                throw .invalidDomain(hostString)
            }
        } else {
            // Non-special: opaque host
            self = .opaque(hostString)
        }
    }
}

// MARK: - CustomStringConvertible

extension WHATWG_URL.URL.Host: CustomStringConvertible {}
