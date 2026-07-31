//
//  WHATWG_Form_URL_Encoded.PercentEncoding.swift
//  swift-whatwg-url
//
//  Authoritative implementation of percent encoding per WHATWG URL Standard Section 5
//  application/x-www-form-urlencoded

import ASCII_Primitives
import ASCII_Serializer_Primitives

extension WHATWG_Form_URL_Encoded {
    /// Percent Encoding Operations
    ///
    /// Authoritative implementations for percent encoding/decoding per WHATWG URL Standard.
    /// Section 5: application/x-www-form-urlencoded
    ///
    /// ## Character Set Rules
    ///
    /// Only these characters remain unencoded:
    /// - ASCII alphanumeric: a-z, A-Z, 0-9
    /// - Special characters: * - . _
    ///
    /// All other characters are percent-encoded as %XX (uppercase hex).
    /// Space (0x20) is encoded as '+' (application/x-www-form-urlencoded) or '%20' (standard percent encoding).
    public enum PercentEncoding {}
}

// MARK: - Encoding

extension WHATWG_Form_URL_Encoded.PercentEncoding {
    /// Percent-encodes a string using application/x-www-form-urlencoded rules
    ///
    /// This is the authoritative implementation per WHATWG URL Standard Section 5.
    ///
    /// - Parameters:
    ///   - string: String to encode
    ///   - space: How space (0x20) is encoded — `.plus` for '+', `.percentEscaped` for '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode("Hello World!")
    /// // Result: "Hello+World%21"
    /// ```
    public static func encode(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> String {
        var result = ""

        for byte in string.utf8 {
            switch byte {
            // ASCII alphanumeric (0-9, A-Z, a-z)
            case _ where byte.ascii.isAlphanumeric:
                result.append(Character(UnicodeScalar(byte)))

            // WHATWG application/x-www-form-urlencoded allowed characters: * - . _
            case UInt8.ascii.asterisk,
                UInt8.ascii.hyphen,
                UInt8.ascii.period,
                UInt8.ascii.underline:
                result.append(Character(UnicodeScalar(byte)))

            // Space: + or %20
            case UInt8.ascii.sp:
                result.append(space == .plus ? "+" : "%20")

            // Everything else: percent-encode
            default:
                // High/low nibbles (`byte >> 4`, `byte & 0x0F`) are structurally 0-15,
                // so `hexDigitUppercase` is always non-nil. Emits uppercase '0'-'9'/'A'-'F'
                // (0x30-0x39, 0x41-0x46) — exact parity with the prior Base16 uppercase table.
                result.append("%")
                result.append(
                    Character(UnicodeScalar(ASCII.Hexadecimal.code(byte >> 4, case: .upper)!))
                )
                result.append(
                    Character(UnicodeScalar(ASCII.Hexadecimal.code(byte & 0x0F, case: .upper)!))
                )
            }
        }

        return result
    }
}

// MARK: - Decoding

extension WHATWG_Form_URL_Encoded.PercentEncoding {
    /// Percent-decodes a string using application/x-www-form-urlencoded rules
    ///
    /// This is the authoritative implementation per WHATWG URL Standard Section 5.
    ///
    /// - Parameters:
    ///   - string: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space (0x20), `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded string
    /// - Throws: `Error` if the input contains invalid percent encoding
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = try WHATWG_Form_URL_Encoded.PercentEncoding.decode("Hello+World%21")
    /// // Result: "Hello World!"
    /// ```
    public static func decode(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(Error) -> String {
        var bytes: [UInt8] = []
        var index = string.startIndex

        while index < string.endIndex {
            let char = string[index]

            if char == "+" && space == .plus {
                bytes.append(UInt8.ascii.sp)
                index = string.index(after: index)
            } else if char == "%" {
                // Need at least 2 more characters for %XX
                let nextIndex = string.index(after: index)
                guard nextIndex < string.endIndex else {
                    throw .unexpectedEndOfInput
                }

                let secondIndex = string.index(after: nextIndex)
                guard secondIndex < string.endIndex else {
                    throw .unexpectedEndOfInput
                }

                let hexString = String(string[nextIndex...secondIndex])
                guard let byte = UInt8(hexString, radix: 16) else {
                    throw .invalidPercentEncoding(
                        position: string.distance(from: string.startIndex, to: index),
                        found: "%" + hexString
                    )
                }

                bytes.append(byte)
                index = string.index(after: secondIndex)
            } else {
                bytes.append(contentsOf: String(char).utf8)
                index = string.index(after: index)
            }
        }

        return String(decoding: bytes, as: UTF8.self)
    }

    /// Percent-decodes a string, returning nil on failure
    ///
    /// Non-throwing convenience variant of `decode(_:space:)`.
    ///
    /// - Parameters:
    ///   - string: Percent-encoded string to decode
    ///   - space: How `+` decodes — `.plus` for space (0x20), `.percentEscaped` to leave it as '+'
    /// - Returns: Decoded string, or nil if invalid percent encoding
    public static func decodeOrNil(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> String? {
        do throws(Error) {
            return try decode(string, space: space)
        } catch {
            return nil
        }
    }
}
