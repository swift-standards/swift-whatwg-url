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

extension WHATWG_URL.PercentEncoding {
    /// Encode sets define which characters should be percent-encoded
    ///
    /// Per WHATWG URL Standard Section 1.3
    enum EncodeSet {
        /// C0 control percent-encode set
        case c0Control

        /// Fragment percent-encode set
        case fragment

        /// Query percent-encode set
        case query

        /// Special query percent-encode set (used in special URLs)
        case specialQuery

        /// Path percent-encode set
        case path

        /// Userinfo percent-encode set
        case userinfo

        /// Component percent-encode set
        case component
    }
}

extension WHATWG_URL.PercentEncoding.EncodeSet {
    func shouldEncode(_ char: Character) -> Bool {
        let value = UInt32(char.utf8.first!)

        // C0 controls: U+0000 to U+001F (NUL through US)
        let isC0Control = value <= UInt32(UInt8.ascii.us)

        // Non-ASCII: above tilde (0x7E)
        let isNonASCII = value > UInt32(UInt8.ascii.tilde)

        // Characters always encoded
        let alwaysEncode =
            char == " " || char == "\"" || char == "<" || char == ">" || char == "`"

        // Check specific encode set rules
        switch self {
        case .c0Control:
            return isC0Control || isNonASCII

        case .fragment:
            return isC0Control || isNonASCII || alwaysEncode || char == "#"

        case .query, .specialQuery:
            return isC0Control || isNonASCII || alwaysEncode || char == "#"

        case .path:
            return isC0Control || isNonASCII || alwaysEncode || char == "?" || char == "{"
                || char == "}"

        case .userinfo:
            return isC0Control || isNonASCII || alwaysEncode || char == "/" || char == ":"
                || char == ";" || char == "=" || char == "@" || char == "[" || char == "\\"
                || char == "]" || char == "^" || char == "|"

        case .component:
            return isC0Control || isNonASCII || alwaysEncode || char == "/" || char == ":"
                || char == ";" || char == "=" || char == "@" || char == "[" || char == "\\"
                || char == "]" || char == "^" || char == "|" || char == "?" || char == "#"
        }
    }
}
