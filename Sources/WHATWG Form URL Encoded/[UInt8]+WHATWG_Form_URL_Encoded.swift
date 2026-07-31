//
//  [UInt8]+WHATWG_Form_URL_Encoded.swift
//  swift-whatwg-url
//
//  WHATWG URL Standard extensions for [UInt8]
//  Provides byte-level percent encoding/decoding per application/x-www-form-urlencoded

import RFC_4648

// MARK: - Namespace Wrapper

extension WHATWG_Form_URL_Encoded {
    /// Namespace for form URL encoded byte array operations
    public struct FormURLEncodedBytes {
        public let bytes: [UInt8]

        @usableFromInline
        internal init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}

// MARK: - [UInt8] Extension for Namespace Access

extension [UInt8] {
    /// Access to form URL encoded operations
    public static var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncodedBytes.Type {
        WHATWG_Form_URL_Encoded.FormURLEncodedBytes.self
    }

    /// Access to form URL encoded operations for this byte array
    public var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncodedBytes {
        WHATWG_Form_URL_Encoded.FormURLEncodedBytes(bytes: self)
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncodedBytes {
    /// Percent-encodes bytes to a string
    ///
    /// Defers to authoritative implementation in `WHATWG_Form_URL_Encoded.PercentEncoding`.
    ///
    /// - Parameter space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func encoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> String {
        WHATWG_Form_URL_Encoded.PercentEncoding.encode(
            String(decoding: self.bytes, as: UTF8.self),
            space: space
        )
    }

    /// Percent-encodes bytes to a string (call syntax)
    @inlinable
    public func callAsFunction(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> String {
        encoded(space: space)
    }
}

// MARK: - Decoding: String → [UInt8]? (percent decoded)

extension [UInt8] {
    /// Creates bytes by percent-decoding a form URL encoded string
    ///
    /// - Parameters:
    ///   - formURLEncoded: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space (0x20), `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded bytes, or nil if invalid percent encoding
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = [UInt8](formURLDecoding: "Hello+%21")
    /// // Result: Optional([72, 101, 108, 108, 111, 32, 33])
    /// ```
    @inlinable
    public init?(
        formURLDecoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        guard let decoded = Self.formURLEncoded.decode(string, space: space) else {
            return nil
        }
        self = decoded
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncodedBytes {
    /// Percent-decodes a form URL encoded string to bytes
    ///
    /// Defers to authoritative implementation in `WHATWG_Form_URL_Encoded.PercentEncoding`.
    ///
    /// - Parameters:
    ///   - string: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space, `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded bytes, or nil if invalid
    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> [UInt8]? {
        guard
            let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decodeOrNil(
                String(string),
                space: space
            )
        else {
            return nil
        }
        return Array(decoded.utf8)
    }
}
