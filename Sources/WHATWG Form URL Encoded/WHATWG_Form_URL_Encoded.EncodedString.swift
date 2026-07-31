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

public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

extension WHATWG_Form_URL_Encoded {
    /// A percent-encoded string per WHATWG URL Standard Section 5
    ///
    /// This type wraps an already-encoded string, providing type safety
    /// to distinguish encoded strings from plain strings.
    ///
    /// ## Creation
    ///
    /// ```swift
    /// // From plain string (encodes it)
    /// let encoded = EncodedString(encoding: "Hello World!")
    /// print(encoded.rawValue)  // "Hello+World%21"
    ///
    /// // From already-encoded string (unchecked)
    /// let trusted = EncodedString(__unchecked: "already%20encoded")
    /// ```
    ///
    /// ## Decoding
    ///
    /// ```swift
    /// let decoded = try encoded.decoded()  // "Hello World!"
    /// ```
    public struct EncodedString: Hashable, Sendable, CustomStringConvertible {
        /// The percent-encoded string value
        public let rawValue: String

        /// Creates from an already percent-encoded string without validation
        ///
        /// Use this initializer when you have a string that is known to be
        /// correctly percent-encoded, such as from a trusted source.
        ///
        /// - Parameter rawValue: An already percent-encoded string
        /// - Warning: No validation is performed. Use only with trusted input.
        public init(__unchecked rawValue: String) {
            self.rawValue = rawValue
        }

        /// Creates by encoding a plain string
        ///
        /// - Parameters:
        ///   - string: The plain string to encode
        ///   - space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
        public init(encoding string: String, space: SpaceEncoding = .plus) {
            self.rawValue = PercentEncoding.encode(string, space: space)
        }
    }
}

extension WHATWG_Form_URL_Encoded.EncodedString {
    /// Decodes to a plain string
    ///
    /// - Parameter space: How `+` decodes — `.plus` for space (0x20), `.percentEscaped` to leave it as '+'
    /// - Returns: The decoded string
    /// - Throws: `PercentEncoding.Error` if the encoding is invalid
    public func decoded(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(WHATWG_Form_URL_Encoded.PercentEncoding.Error) -> String {
        try WHATWG_Form_URL_Encoded.PercentEncoding.decode(rawValue, space: space)
    }

    /// The percent-encoded string value
    public var description: String {
        rawValue
    }
}

// MARK: - ASCII.Serializable ([FAM-012] text sibling)

extension WHATWG_Form_URL_Encoded.EncodedString: ASCII.Serializable {
    /// Serializes the encoded string as its percent-encoded ASCII text.
    ///
    /// [FAM-012] text sibling — emits the typed text substrate `ASCII.Code`.
    /// A percent-encoded string is **ASCII-only** (WHATWG §5 form encoding is an
    /// ASCII text form); its byte view is a text projection, not a wire codec, so
    /// there is no `Binary.Serializable` peer (clause-7).
    public static func serialize<Buffer>(
        _ instance: WHATWG_Form_URL_Encoded.EncodedString,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        // swift-linter:disable:next raw value access
        // REASON: EncodedString's own ASCII.Serializable conformance — same-package
        // implementation reading its own wrapped value at the type's boundary.
        // swift-linter:disable:next chained rawvalue access
        // REASON: typed-system bottom-out — the wrapper's own text-serialization boundary.
        for byte in instance.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

// MARK: - ASCII.Parseable ([FAM-012] parse — free-standing init)

extension WHATWG_Form_URL_Encoded.EncodedString: ASCII.Parseable {
    /// Interprets ASCII bytes as an already percent-encoded string (unchecked).
    ///
    /// No validation is performed — use `decoded()` to validate. Total by
    /// construction (an already-encoded string is accepted verbatim).
    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) where Bytes.Element == Byte {
        // swift-linter:disable:next unchecked call site
        // REASON: extension-init internals — same-package construction of the wrapper's
        // own boundary, permitted use per [CONV-001].
        self.init(__unchecked: String(decoding: bytes, as: UTF8.self))
    }
}

// MARK: - ExpressibleByStringLiteral

extension WHATWG_Form_URL_Encoded.EncodedString: ExpressibleByStringLiteral {
    /// Creates an encoded string from a string literal
    ///
    /// The literal is treated as an already-encoded string (unchecked).
    /// Use `EncodedString(encoding:)` to encode a plain string.
    public init(stringLiteral value: String) {
        // swift-linter:disable:next unchecked call site
        // REASON: extension-init internals — same-package construction of the wrapper's
        // own boundary, permitted use per [CONV-001].
        self.init(__unchecked: value)
    }
}
