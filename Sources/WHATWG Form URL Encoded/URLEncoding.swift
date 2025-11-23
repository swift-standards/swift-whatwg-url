import RFC_4648

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
/// let encoded = WHATWG_Form_URL_Encoded.serialize([
///     ("name", "John Doe"),
///     ("email", "john@example.com")
/// ])
/// // Result: "name=John+Doe&email=john%40example.com"
///
/// // Parse application/x-www-form-urlencoded format
/// let pairs = WHATWG_Form_URL_Encoded.parse("name=John+Doe&email=john%40example.com")
/// // Result: [("name", "John Doe"), ("email", "john@example.com")]
/// ```
public enum WHATWG_Form_URL_Encoded {}

extension WHATWG_Form_URL_Encoded {
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
    /// let encoded = WHATWG_Form_URL_Encoded.serialize([
    ///     ("name", "John Doe"),
    ///     ("active", "true")
    /// ])
    /// // Result: "name=John+Doe&active=true"
    /// ```
    public static func serialize(_ pairs: [(String, String)]) -> String {
        pairs
            .map { name, value in
                let encodedName = PercentEncoding.encode(name, spaceAsPlus: true)
                let encodedValue = PercentEncoding.encode(value, spaceAsPlus: true)
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
    /// let pairs = WHATWG_Form_URL_Encoded.parse("name=John+Doe&active=true")
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

                guard let decodedName = PercentEncoding.decode(name, plusAsSpace: true),
                    let decodedValue = PercentEncoding.decode(value, plusAsSpace: true)
                else {
                    return nil
                }

                return (decodedName, decodedValue)
            }
    }
}
