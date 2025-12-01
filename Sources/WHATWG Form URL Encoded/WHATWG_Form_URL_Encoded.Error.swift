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

extension WHATWG_Form_URL_Encoded.PercentEncoding {
    /// Errors that can occur during percent encoding/decoding operations
    ///
    /// Per WHATWG URL Standard Section 5: application/x-www-form-urlencoded
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Invalid percent encoding sequence at given position
        case invalidPercentEncoding(position: Int, found: String)

        /// Invalid hexadecimal digit in percent encoding
        case invalidHexDigit(Character)

        /// The decoded bytes are not valid UTF-8
        case invalidUTF8Sequence

        /// Unexpected end of input while parsing percent encoding
        case unexpectedEndOfInput
    }
}
