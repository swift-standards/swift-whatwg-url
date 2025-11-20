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

/// A host as defined by the WHATWG URL Standard
///
/// A host is a domain, an IPv4 address, an IPv6 address, an opaque host, or an empty host.
/// Typically a host serves as a network address, but it is sometimes used as an opaque identifier
/// in URLs where a network address is not necessary.
public enum URLHost: Hashable, Sendable {
    /// A domain (e.g., "example.com", with IDNA support)
    case domain(Domain)

    /// An IPv4 address represented as four 8-bit integers
    case ipv4(UInt8, UInt8, UInt8, UInt8)

    /// An IPv6 address represented as eight 16-bit integers
    case ipv6(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)

    /// An opaque host (non-special schemes)
    case opaque(String)

    /// An empty host (allowed for file: URLs)
    case empty
}

extension URLHost {
    /// Serializes the host to its string representation
    public var serialized: String {
        switch self {
        case .domain(let domain):
            return domain.name

        case .ipv4(let a, let b, let c, let d):
            return "\(a).\(b).\(c).\(d)"

        case .ipv6(let a, let b, let c, let d, let e, let f, let g, let h):
            // IPv6 serialization with compression
            return serializeIPv6(a, b, c, d, e, f, g, h)

        case .opaque(let host):
            return host

        case .empty:
            return ""
        }
    }

    /// Serializes an IPv6 address with proper compression
    private func serializeIPv6(
        _ a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16,
        _ e: UInt16, _ f: UInt16, _ g: UInt16, _ h: UInt16
    ) -> String {
        let pieces = [a, b, c, d, e, f, g, h]

        // Find longest run of zeros for compression
        var longestZeroRun: (start: Int, length: Int) = (0, 0)
        var currentZeroRun: (start: Int, length: Int) = (0, 0)
        var inZeroRun = false

        for (index, piece) in pieces.enumerated() {
            if piece == 0 {
                if !inZeroRun {
                    currentZeroRun = (index, 1)
                    inZeroRun = true
                } else {
                    currentZeroRun.length += 1
                }

                if currentZeroRun.length > longestZeroRun.length {
                    longestZeroRun = currentZeroRun
                }
            } else {
                inZeroRun = false
            }
        }

        // Build the IPv6 string
        var result = "["
        let compress = longestZeroRun.length > 1

        for index in 0..<8 {
            if compress && index == longestZeroRun.start {
                result += "::"
                // Skip the compressed zeros
                continue
            } else if compress && index > longestZeroRun.start && index < longestZeroRun.start + longestZeroRun.length {
                continue
            }

            if index > 0 && !(compress && index == longestZeroRun.start + longestZeroRun.length) {
                result += ":"
            }

            result += String(pieces[index], radix: 16, uppercase: false)
        }

        result += "]"
        return result
    }
}
