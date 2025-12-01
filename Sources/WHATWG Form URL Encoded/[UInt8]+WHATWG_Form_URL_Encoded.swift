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
    /// - Parameter spaceAsPlus: If true, space encoded as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func encoded(spaceAsPlus: Bool = true) -> String {
        WHATWG_Form_URL_Encoded.PercentEncoding.encode(String(decoding: self.bytes, as: UTF8.self), spaceAsPlus: spaceAsPlus)
    }

    /// Percent-encodes bytes to a string (call syntax)
    @inlinable
    public func callAsFunction(spaceAsPlus: Bool = true) -> String {
        encoded(spaceAsPlus: spaceAsPlus)
    }
}

// MARK: - Decoding: String → [UInt8]? (percent decoded)

extension [UInt8] {
    /// Creates bytes by percent-decoding a form URL encoded string
    ///
    /// - Parameters:
    ///   - formURLEncoded: Percent-encoded string to decode
    ///   - plusAsSpace: If true, '+' decoded as space (0x20)
    /// - Returns: Decoded bytes, or nil if invalid percent encoding
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = [UInt8](formURLDecoding: "Hello+%21")
    /// // Result: Optional([72, 101, 108, 108, 111, 32, 33])
    /// ```
    @inlinable
    public init?(formURLDecoding string: some StringProtocol, plusAsSpace: Bool = true) {
        guard let decoded = Self.formURLEncoded.decode(string, plusAsSpace: plusAsSpace) else {
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
    ///   - plusAsSpace: If true, '+' decoded as space
    /// - Returns: Decoded bytes, or nil if invalid
    @inlinable
    public static func decode(_ string: some StringProtocol, plusAsSpace: Bool = true) -> [UInt8]? {
        guard let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decodeOrNil(String(string), plusAsSpace: plusAsSpace) else {
            return nil
        }
        return Array(decoded.utf8)
    }
}
