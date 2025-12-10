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

public import RFC_4291
public import RFC_791

extension RFC_4291.IPv6.Address {
    /// Parse an IPv6 address per WHATWG URL Standard Section 4.7
    ///
    /// WHATWG URL parsing handles:
    /// - Standard colon-hex notation: `2001:db8::1`
    /// - Compressed zeros: `2001:db8::1`
    /// - Embedded IPv4: `::ffff:192.0.2.1`
    /// - Brackets stripped: `[2001:db8::1]` → `2001:db8::1`
    /// - Zone IDs removed: `fe80::1%eth0` → `fe80::1`
    ///
    /// This is **WHATWG-specific** preprocessing before RFC 4291 parsing.
    ///
    /// - Parameter whatwgString: String in WHATWG IPv6 format
    /// - Returns: Parsed address, or nil if invalid
    public init?(whatwgString: String) {
        var input = whatwgString

        // Strip brackets if present (WHATWG requires this)
        if input.hasPrefix("[") && input.hasSuffix("]") {
            input = String(input.dropFirst().dropLast())
        }

        // Remove zone ID if present (e.g., %eth0)
        if let percentIndex = input.firstIndex(of: "%") {
            input = String(input[..<percentIndex])
        }

        // Parse using RFC 4291 standard parser
        guard let addr = Self.parseRFC4291(input) else {
            return nil
        }

        self = addr
    }

    /// Parse RFC 4291 standard IPv6 notation
    ///
    /// Supports:
    /// - Full form: `2001:0db8:0000:0000:0000:0000:0000:0001`
    /// - Compressed: `2001:db8::1`
    /// - IPv4-embedded: `::ffff:192.0.2.1`
    ///
    /// - Parameter string: IPv6 address string
    /// - Returns: Parsed address, or nil if invalid
    private static func parseRFC4291(_ string: String) -> Self? {
        // Handle IPv4-embedded format (::ffff:192.0.2.1)
        if let colonIndex = string.lastIndex(of: ":"),
           string[string.index(after: colonIndex)...].contains(".") {
            return parseIPv4Embedded(string)
        }

        let parts = string.split(separator: ":", omittingEmptySubsequences: false)

        // Check for :: (compression)
        let compressionIndex = parts.firstIndex(where: { $0.isEmpty })

        var pieces: [UInt16] = []
        var beforeCompression: [UInt16] = []
        var afterCompression: [UInt16] = []

        if let compIdx = compressionIndex {
            // Parse before compression
            for i in 0..<compIdx {
                guard let piece = UInt16(parts[i], radix: 16), parts[i].count <= 4 else {
                    return nil
                }
                beforeCompression.append(piece)
            }

            // Parse after compression (skip consecutive empty parts)
            var skipEmpty = true
            for i in (compIdx + 1)..<parts.count {
                if parts[i].isEmpty && skipEmpty {
                    continue
                }
                skipEmpty = false

                guard !parts[i].isEmpty else { return nil }
                guard let piece = UInt16(parts[i], radix: 16), parts[i].count <= 4 else {
                    return nil
                }
                afterCompression.append(piece)
            }

            // Fill with zeros
            let totalPieces = beforeCompression.count + afterCompression.count
            guard totalPieces < 8 else { return nil }

            let zerosCount = 8 - totalPieces
            pieces = beforeCompression + Array(repeating: 0, count: zerosCount) + afterCompression

        } else {
            // No compression - must have exactly 8 pieces
            guard parts.count == 8 else { return nil }

            for part in parts {
                guard let piece = UInt16(part, radix: 16), part.count <= 4 else {
                    return nil
                }
                pieces.append(piece)
            }
        }

        guard pieces.count == 8 else { return nil }

        return Self(
            pieces[0], pieces[1], pieces[2], pieces[3],
            pieces[4], pieces[5], pieces[6], pieces[7]
        )
    }

    /// Parse IPv4-embedded IPv6 address (e.g., ::ffff:192.0.2.1)
    private static func parseIPv4Embedded(_ string: String) -> Self? {
        guard let lastColon = string.lastIndex(of: ":") else {
            return nil
        }

        let ipv6Part = String(string[..<lastColon])
        let ipv4Part = String(string[string.index(after: lastColon)...])

        // Parse IPv4 part using WHATWG parser
        guard let ipv4 = RFC_791.IPv4.Address(whatwgString: ipv4Part) else {
            return nil
        }

        // Parse IPv6 prefix part (e.g., "::ffff" from "::ffff:192.0.2.1")
        let parts = ipv6Part.split(separator: ":", omittingEmptySubsequences: false)

        var pieces: [UInt16] = []
        var compressionSeen = false

        for part in parts {
            if part.isEmpty {
                if !compressionSeen {
                    // Compression - calculate how many zeros to fill
                    // We need 6 pieces total for the IPv6 part (IPv4 takes last 2)
                    compressionSeen = true
                    let remainingParts = parts.dropFirst(pieces.count + 1).filter { !$0.isEmpty }.count
                    let zerosCount = 6 - pieces.count - remainingParts
                    if zerosCount > 0 {
                        pieces.append(contentsOf: Array(repeating: 0, count: zerosCount))
                    }
                }
                // Skip additional empty parts from ::
            } else {
                guard let piece = UInt16(part, radix: 16), part.count <= 4 else {
                    return nil
                }
                pieces.append(piece)
            }
        }

        // Ensure we have exactly 6 pieces before IPv4
        guard pieces.count == 6 else { return nil }

        // Convert IPv4 to two 16-bit pieces
        let octets = ipv4.octets
        let piece6 = UInt16(octets.0) << 8 | UInt16(octets.1)
        let piece7 = UInt16(octets.2) << 8 | UInt16(octets.3)

        pieces.append(piece6)
        pieces.append(piece7)

        return Self(
            pieces[0], pieces[1], pieces[2], pieces[3],
            pieces[4], pieces[5], pieces[6], pieces[7]
        )
    }
}
