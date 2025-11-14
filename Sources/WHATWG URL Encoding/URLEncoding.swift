import Foundation

/// WHATWG URL Standard implementation for application/x-www-form-urlencoded
///
/// This module implements the WHATWG URL Standard's specification for
/// application/x-www-form-urlencoded encoding and decoding.
///
/// ## Reference
///
/// WHATWG URL Living Standard:
/// https://url.spec.whatwg.org/#application/x-www-form-urlencoded
///
/// ## Example
///
/// ```swift
/// // Serialize to application/x-www-form-urlencoded format
/// let encoded = WHATWG_URL_Encoding.serialize([
///     ("name", "John Doe"),
///     ("email", "john@example.com")
/// ])
/// // Result: "name=John+Doe&email=john%40example.com"
///
/// // Parse application/x-www-form-urlencoded format
/// let pairs = WHATWG_URL_Encoding.parse("name=John+Doe&email=john%40example.com")
/// // Result: [("name", "John Doe"), ("email", "john@example.com")]
/// ```
public enum WHATWG_URL_Encoding {}

extension WHATWG_URL_Encoding {
    /// Serializes name-value pairs to application/x-www-form-urlencoded format
    ///
    /// Implements the WHATWG URL Standard's serialization algorithm.
    ///
    /// - Parameter pairs: Array of name-value tuples to serialize
    /// - Returns: application/x-www-form-urlencoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = WHATWG_URL_Encoding.serialize([
    ///     ("name", "John Doe"),
    ///     ("active", "true")
    /// ])
    /// // Result: "name=John+Doe&active=true"
    /// ```
    public static func serialize(_ pairs: [(String, String)]) -> String {
        pairs
            .map { name, value in
                let encodedName = percentEncode(name, spaceAsPlus: true)
                let encodedValue = percentEncode(value, spaceAsPlus: true)
                return "\(encodedName)=\(encodedValue)"
            }
            .joined(separator: "&")
    }

    /// Parses application/x-www-form-urlencoded string to name-value pairs
    ///
    /// Implements the WHATWG URL Standard's parser algorithm.
    ///
    /// - Parameter input: application/x-www-form-urlencoded string
    /// - Returns: Array of name-value tuples
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pairs = WHATWG_URL_Encoding.parse("name=John+Doe&active=true")
    /// // Result: [("name", "John Doe"), ("active", "true")]
    /// ```
    public static func parse(_ input: String) -> [(String, String)] {
        // Handle empty input
        guard !input.isEmpty else { return [] }

        return
            input
            .split(separator: "&", omittingEmptySubsequences: false)
            .compactMap { pair in
                // Skip empty pairs (e.g., from "&&")
                guard !pair.isEmpty else { return nil }

                let components = pair.split(
                    separator: "=",
                    maxSplits: 1,
                    omittingEmptySubsequences: false
                )
                guard !components.isEmpty else { return nil }

                let name = String(components[0])
                let value = components.count > 1 ? String(components[1]) : ""

                guard let decodedName = percentDecode(name, plusAsSpace: true),
                    let decodedValue = percentDecode(value, plusAsSpace: true)
                else {
                    return nil
                }

                return (decodedName, decodedValue)
            }
    }

    /// Percent-encodes a string using the WHATWG application/x-www-form-urlencoded character set
    ///
    /// According to the WHATWG URL Standard, only the following characters are left unencoded:
    /// - ASCII alphanumeric (a-z, A-Z, 0-9)
    /// - Asterisk (*)
    /// - Hyphen (-)
    /// - Period (.)
    /// - Underscore (_)
    ///
    /// All other characters are percent-encoded. Space (0x20) is encoded as '+' when `spaceAsPlus` is true.
    ///
    /// - Parameters:
    ///   - string: String to encode
    ///   - spaceAsPlus: If true, space characters are encoded as '+', otherwise as '%20'
    /// - Returns: Percent-encoded string
    ///
    /// ## Example
    ///
    /// ```swift
    /// let encoded = WHATWG_URL_Encoding.percentEncode("Hello World!", spaceAsPlus: true)
    /// // Result: "Hello+World%21"
    /// ```
    public static func percentEncode(_ string: String, spaceAsPlus: Bool = true) -> String {
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
                result.append(String(format: "%%%02X", character))
            }
        }

        return result
    }

    /// Percent-decodes a string, handling WHATWG application/x-www-form-urlencoded format
    ///
    /// - Parameters:
    ///   - string: String to decode
    ///   - plusAsSpace: If true, '+' characters are decoded as space, otherwise left as '+'
    /// - Returns: Decoded string, or nil if decoding fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = WHATWG_URL_Encoding.percentDecode("Hello+World%21", plusAsSpace: true)
    /// // Result: "Hello World!"
    /// ```
    public static func percentDecode(_ string: String, plusAsSpace: Bool = true) -> String? {
        var bytes: [UInt8] = []
        var index = string.startIndex

        while index < string.endIndex {
            let char = string[index]

            if char == "+" && plusAsSpace {
                bytes.append(contentsOf: " ".utf8)
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

        return String(bytes: bytes, encoding: .utf8)
    }
}
