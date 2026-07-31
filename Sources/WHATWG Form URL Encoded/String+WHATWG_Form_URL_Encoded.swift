//
//  String+WHATWG_Form_URL_Encoded.swift
//  swift-whatwg-url
//
//  WHATWG URL Standard extensions for String
//  Provides percent encoding/decoding per application/x-www-form-urlencoded

import RFC_4648

// MARK: - Namespace Wrapper

extension WHATWG_Form_URL_Encoded {
    /// Namespace for form URL encoded string operations
    public struct FormURLEncoded<S: StringProtocol> {
        public let value: S

        @usableFromInline
        internal init(_ value: S) {
            self.value = value
        }
    }
}

// MARK: - StringProtocol Extension for Namespace Access

extension StringProtocol {
    /// Access to form URL encoded operations
    public static var formURL: WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.Type {
        WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.self
    }

    /// Access to form URL encoded operations for this string
    public var formURL: WHATWG_Form_URL_Encoded.FormURLEncoded<Self> {
        WHATWG_Form_URL_Encoded.FormURLEncoded(self)
    }
}

// MARK: - Encoding: String → String (percent encoded)

extension StringProtocol {
    /// Creates a percent-encoded string using application/x-www-form-urlencoded rules
    ///
    /// Per WHATWG URL Standard, only these characters remain unencoded:
    /// - ASCII alphanumeric (a-z, A-Z, 0-9)
    /// - Asterisk (*), Hyphen (-), Period (.), Underscore (_)
    ///
    /// Space is encoded as '+' when `space` is `.plus` (default), otherwise '%20'.
    ///
    /// - Parameter space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = String(formURLEncoding: "Hello World!")
    /// // Result: "Hello+World%21"
    ///
    /// let encoded2 = String(formURLEncoding: "Hello World!", space: .percentEscaped)
    /// // Result: "Hello%20World%21"
    /// ```
    @inlinable
    public init(
        formURLEncoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        self = Self.formURL.encode(string, space: space)
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncoded {
    /// Percent-encodes a string using application/x-www-form-urlencoded rules
    ///
    /// Defers to authoritative implementation in `WHATWG_Form_URL_Encoded.PercentEncoding`.
    ///
    /// - Parameters:
    ///   - string: String to encode
    ///   - space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public static func encode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> S {
        S(WHATWG_Form_URL_Encoded.PercentEncoding.encode(String(string), space: space))!
    }

    /// Percent-encodes this string
    ///
    /// - Parameter space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func encoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S {
        Self.encode(self.value, space: space)
    }

    /// Percent-encodes this string (call syntax)
    ///
    /// - Parameter space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func callAsFunction(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S {
        encoded(space: space)
    }
}

// MARK: - Decoding: String → String? (percent decoded)

extension StringProtocol {
    /// Creates a string by percent-decoding a form URL encoded string
    ///
    /// Decodes percent-encoded sequences (%XX) and optionally converts '+' to space.
    ///
    /// - Parameters:
    ///   - formURLEncoded: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space, `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded string, or nil if invalid percent encoding
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = String(formURLDecoding: "Hello+World%21")
    /// // Result: Optional("Hello World!")
    ///
    /// let invalid = String(formURLDecoding: "Invalid%ZZ")
    /// // Result: nil
    /// ```
    @inlinable
    public init?(
        formURLDecoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        guard let decoded = Self.formURL.decode(string, space: space) else {
            return nil
        }
        self = decoded
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncoded {
    /// Percent-decodes a form URL encoded string
    ///
    /// Defers to authoritative implementation in `WHATWG_Form_URL_Encoded.PercentEncoding`.
    ///
    /// - Parameters:
    ///   - string: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space, `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded string, or nil if invalid
    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> S? {
        guard
            let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decodeOrNil(
                String(string),
                space: space
            )
        else {
            return nil
        }
        return S(decoded)
    }

    /// Percent-decodes this string
    ///
    /// - Parameter space: How `+` decodes — `.plus` for space, `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded string, or nil if invalid
    @inlinable
    public func decoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S? {
        Self.decode(self.value, space: space)
    }
}

// MARK: - Encoding: [UInt8] → String (percent encoded)

extension String {
    /// Creates a percent-encoded string from bytes using application/x-www-form-urlencoded rules
    ///
    /// - Parameters:
    ///   - formURLEncodingBytes: The bytes to encode
    ///   - space: How space (0x20) encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111, 32, 33]  // "Hello !"
    /// let encoded = String(formURLEncodingBytes: bytes)
    /// // Result: "Hello+%21"
    /// ```
    @inlinable
    public init(
        formURLEncodingBytes bytes: [UInt8],
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        let decoded = String(decoding: bytes, as: UTF8.self)
        self = WHATWG_Form_URL_Encoded.PercentEncoding.encode(decoded, space: space)
    }
}

// MARK: - EncodedString Convenience

extension String {
    /// Encodes this string using application/x-www-form-urlencoded rules
    ///
    /// Returns an `EncodedString` wrapper for type-safe handling of encoded strings.
    ///
    /// - Parameter space: How space encodes — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: An EncodedString containing the percent-encoded value
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = "Hello World!".formURLEncodedString()
    /// print(encoded.rawValue)  // "Hello+World%21"
    ///
    /// let decoded = try encoded.decoded()  // "Hello World!"
    /// ```
    public func formURLEncodedString(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> WHATWG_Form_URL_Encoded.EncodedString {
        WHATWG_Form_URL_Encoded.EncodedString(encoding: self, space: space)
    }

    /// Decodes this string from application/x-www-form-urlencoded format
    ///
    /// - Parameter space: How `+` decodes — `.plus` for space (0x20), `.percentEscaped` to leave it as '+'
    /// - Returns: The decoded string
    /// - Throws: `PercentEncoding.Error` if the encoding is invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = try "Hello+World%21".decodingFormURLEncoded()
    /// // Result: "Hello World!"
    /// ```
    public func decodingFormURLEncoded(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(WHATWG_Form_URL_Encoded.PercentEncoding.Error) -> String {
        try WHATWG_Form_URL_Encoded.PercentEncoding.decode(self, space: space)
    }
}
