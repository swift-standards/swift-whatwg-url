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

public import RFC_791

extension RFC_791.IPv4.Address {
    /// Parse an IPv4 address per WHATWG URL Standard Section 4.6
    ///
    /// The WHATWG URL spec extends standard IPv4 parsing to support:
    /// - Decimal: 192.168.1.1 (standard RFC 791)
    /// - Octal: 0300.0250.01.01 (leading 0)
    /// - Hex: 0xC0.0xA8.0x1.0x1 (0x prefix)
    /// - Mixed: 192.0xA8.1.1 (different bases)
    /// - Compressed: 192.168.257 (last part absorbs bits)
    /// - Single number: 3232235777 (entire address)
    ///
    /// This is **WHATWG-specific** - not part of RFC 791.
    /// RFC 791 only defines standard dotted-decimal notation.
    ///
    /// - Parameter whatwgString: String in any WHATWG-supported IPv4 format
    /// - Returns: Parsed address, or nil if invalid
    public init?(whatwgString: String) {
        let parts = whatwgString.split(separator: ".")

        guard !parts.isEmpty && parts.count <= 4 else {
            return nil
        }

        // Parse each part (decimal, octal, or hex)
        var numbers: [UInt32] = []
        for part in parts {
            guard let num = Self.parseWHATWGNumber(String(part)) else {
                return nil
            }
            numbers.append(num)
        }

        // Construct address from numbers
        guard let address = Self.constructFromWHATWGNumbers(numbers) else {
            return nil
        }

        self = address
    }

    /// Parse a WHATWG IPv4 number component (decimal/octal/hex)
    private static func parseWHATWGNumber(_ string: String) -> UInt32? {
        guard !string.isEmpty else { return nil }

        let chars = Array(string)

        // Hexadecimal: 0x or 0X prefix
        if chars.count > 2 && chars[0] == "0" && (chars[1] == "x" || chars[1] == "X") {
            let hex = String(chars[2...])
            return UInt32(hex, radix: 16)
        }

        // Octal: leading 0
        if chars.count > 1 && chars[0] == "0" {
            let octal = String(chars[1...])
            guard octal.allSatisfy({ $0 >= "0" && $0 <= "7" }) else {
                return nil
            }
            return UInt32(octal, radix: 8)
        }

        // Decimal
        return UInt32(string, radix: 10)
    }

    /// Construct IPv4 address from WHATWG number format
    private static func constructFromWHATWGNumbers(_ numbers: [UInt32]) -> Self? {
        // All but last must be < 256
        for i in 0..<(numbers.count - 1) {
            guard numbers[i] < 256 else { return nil }
        }

        var address: UInt32 = 0

        switch numbers.count {
        case 1:
            address = numbers[0]
        case 2:
            guard numbers[1] < (1 << 24) else { return nil }
            address = (numbers[0] << 24) | numbers[1]
        case 3:
            guard numbers[2] < (1 << 16) else { return nil }
            address = (numbers[0] << 24) | (numbers[1] << 16) | numbers[2]
        case 4:
            guard numbers[3] < 256 else { return nil }
            address = (numbers[0] << 24) | (numbers[1] << 16) | (numbers[2] << 8) | numbers[3]
        default:
            return nil
        }

        let byte1 = UInt8((address >> 24) & 0xFF)
        let byte2 = UInt8((address >> 16) & 0xFF)
        let byte3 = UInt8((address >> 8) & 0xFF)
        let byte4 = UInt8(address & 0xFF)

        return Self(byte1, byte2, byte3, byte4)
    }
}
