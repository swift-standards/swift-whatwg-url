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
    public static var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.Type {
        WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.self
    }

    /// Access to form URL encoded operations for this string
    public var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncoded<Self> {
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
    /// Space is encoded as '+' when `spaceAsPlus` is true (default), otherwise '%20'.
    ///
    /// - Parameter spaceAsPlus: If true, encodes space as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = String(formURLEncoding: "Hello World!")
    /// // Result: "Hello+World%21"
    ///
    /// let encoded2 = String(formURLEncoding: "Hello World!", spaceAsPlus: false)
    /// // Result: "Hello%20World%21"
    /// ```
    @inlinable
    public init(formURLEncoding string: some StringProtocol, spaceAsPlus: Bool = true) {
        self = Self.formURLEncoded.encode(string, spaceAsPlus: spaceAsPlus)
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncoded {
    /// Percent-encodes a string using application/x-www-form-urlencoded rules
    ///
    /// Defers to authoritative implementation in `WHATWG_Form_URL_Encoded.PercentEncoding`.
    ///
    /// - Parameters:
    ///   - string: String to encode
    ///   - spaceAsPlus: If true, space encoded as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public static func encode(_ string: some StringProtocol, spaceAsPlus: Bool = true) -> S {
        S(WHATWG_Form_URL_Encoded.PercentEncoding.encode(String(string), spaceAsPlus: spaceAsPlus))!
    }

    /// Percent-encodes this string
    ///
    /// - Parameter spaceAsPlus: If true, space encoded as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func encoded(spaceAsPlus: Bool = true) -> S {
        Self.encode(self.value, spaceAsPlus: spaceAsPlus)
    }

    /// Percent-encodes this string (call syntax)
    ///
    /// - Parameter spaceAsPlus: If true, space encoded as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    @inlinable
    public func callAsFunction(spaceAsPlus: Bool = true) -> S {
        encoded(spaceAsPlus: spaceAsPlus)
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
    ///   - plusAsSpace: If true, '+' decoded as space, otherwise left as '+'
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
    public init?(formURLDecoding string: some StringProtocol, plusAsSpace: Bool = true) {
        guard let decoded = Self.formURLEncoded.decode(string, plusAsSpace: plusAsSpace) else {
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
    ///   - plusAsSpace: If true, '+' decoded as space
    /// - Returns: Decoded string, or nil if invalid
    @inlinable
    public static func decode(_ string: some StringProtocol, plusAsSpace: Bool = true) -> S? {
        guard let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decode(String(string), plusAsSpace: plusAsSpace) else {
            return nil
        }
        return S(decoded)
    }

    /// Percent-decodes this string
    ///
    /// - Parameter plusAsSpace: If true, '+' decoded as space
    /// - Returns: Decoded string, or nil if invalid
    @inlinable
    public func decoded(plusAsSpace: Bool = true) -> S? {
        Self.decode(self.value, plusAsSpace: plusAsSpace)
    }
}

// MARK: - Encoding: [UInt8] → String (percent encoded)

extension String {
    /// Creates a percent-encoded string from bytes using application/x-www-form-urlencoded rules
    ///
    /// - Parameters:
    ///   - formURLEncodingBytes: The bytes to encode
    ///   - spaceAsPlus: If true, encodes space (0x20) as '+', otherwise '%20'
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
    public init(formURLEncodingBytes bytes: [UInt8], spaceAsPlus: Bool = true) {
        let decoded = String(decoding: bytes, as: UTF8.self)
        self = WHATWG_Form_URL_Encoded.PercentEncoding.encode(decoded, spaceAsPlus: spaceAsPlus)
    }
}
