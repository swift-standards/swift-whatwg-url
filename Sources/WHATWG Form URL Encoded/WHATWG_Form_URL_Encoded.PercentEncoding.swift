//
//  WHATWG_Form_URL_Encoded.PercentEncoding.swift
//  swift-whatwg-url
//
//  Authoritative implementation of percent encoding per WHATWG URL Standard Section 5
//  application/x-www-form-urlencoded

import RFC_4648

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
    ///   - spaceAsPlus: If true, space (0x20) encoded as '+', otherwise '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode("Hello World!")
    /// // Result: "Hello+World%21"
    /// ```
    public static func encode(_ string: String, spaceAsPlus: Bool = true) -> String {
        var result = ""

        for character in string.utf8 {
            switch character {
            // ASCII alphanumeric
            case 0x30...0x39,  // 0-9
                0x41...0x5A,  // A-Z
                0x61...0x7A:  // a-z
                result.append(Character(UnicodeScalar(character)))

            // WHATWG application/x-www-form-urlencoded allowed characters
            case 0x2A,  // *
                0x2D,  // -
                0x2E,  // .
                0x5F:  // _
                result.append(Character(UnicodeScalar(character)))

            // Space: + or %20
            case 0x20:  // space
                result.append(spaceAsPlus ? "+" : "%20")

            // Everything else: percent-encode
            default:
                let hexTable = RFC_4648.Base16.encodingTableUppercase.encode
                result.append("%")
                result.append(Character(UnicodeScalar(hexTable[Int(character >> 4)])))
                result.append(Character(UnicodeScalar(hexTable[Int(character & 0x0F)])))
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
    ///   - plusAsSpace: If true, '+' decoded as space (0x20), otherwise left as '+'
    /// - Returns: Decoded string, or nil if invalid percent encoding
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decode("Hello+World%21")
    /// // Result: Optional("Hello World!")
    /// ```
    public static func decode(_ string: String, plusAsSpace: Bool = true) -> String? {
        var bytes: [UInt8] = []
        var index = string.startIndex

        while index < string.endIndex {
            let char = string[index]

            if char == "+" && plusAsSpace {
                bytes.append(0x20)  // space
                index = string.index(after: index)
            } else if char == "%" {
                // Need at least 2 more characters for %XX
                let nextIndex = string.index(after: index)
                guard nextIndex < string.endIndex else { return nil }

                let secondIndex = string.index(after: nextIndex)
                guard secondIndex < string.endIndex else { return nil }

                let hexString = String(string[nextIndex...secondIndex])
                guard let byte = UInt8(hexString, radix: 16) else { return nil }

                bytes.append(byte)
                index = string.index(after: secondIndex)
            } else {
                bytes.append(contentsOf: String(char).utf8)
                index = string.index(after: index)
            }
        }

        return String(decoding: bytes, as: UTF8.self)
    }
}
