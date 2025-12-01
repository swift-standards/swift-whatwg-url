import Testing
import Foundation

@testable import WHATWG_Form_URL_Encoded

/// Tests that compare WHATWG URL encoding against Foundation's URLComponents encoding
///
/// These tests demonstrate the key differences mentioned in the README:
/// 1. Space encoding: WHATWG uses `+`, Foundation uses `%20`
/// 2. Character set: WHATWG only leaves alphanumeric + `*-._` unencoded
/// 3. Specification compliance: WHATWG follows the exact WHATWG algorithm
@Suite
struct `Foundation Comparison Tests` {

    // MARK: - Space Encoding Differences

    @Test
    func `Space encoding: WHATWG uses + vs Foundation uses %20`() throws {
        let input = "Hello World"

        // WHATWG encoding (this package)
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World", "WHATWG should encode space as +")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World", "Foundation should encode space as %20")

        // They differ in space encoding
        #expect(whatwgEncoded != foundationEncoded, "WHATWG and Foundation should differ on space encoding")
    }

    @Test
    func `Multiple spaces: WHATWG vs Foundation`() throws {
        let input = "first second third"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "first+second+third")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "first%20second%20third")
    }

    // MARK: - Character Set Differences

    @Test
    func `Exclamation mark: WHATWG encodes, Foundation may not`() throws {
        let input = "Hello World!"

        // WHATWG encoding
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World%21", "WHATWG should encode ! as %21")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        // Foundation is more permissive - it leaves ! unencoded
        #expect(foundationEncoded == "Hello%20World!", "Foundation leaves ! unencoded")
    }

    @Test
    func `Tilde: WHATWG encodes, Foundation leaves unencoded`() throws {
        let input = "test~value"

        // WHATWG encoding - tilde is NOT in the allowed set (*-._)
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "test%7E" + "value", "WHATWG should encode ~ as %7E")

        // Foundation encoding - more permissive
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "test~value", "Foundation leaves ~ unencoded")
    }

    @Test
    func `Parentheses: WHATWG encodes, Foundation may not`() throws {
        let input = "func(arg)"

        // WHATWG encoding
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "func%28arg%29", "WHATWG should encode parentheses")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        // Foundation is more permissive
        #expect(foundationEncoded == "func(arg)", "Foundation leaves parentheses unencoded")
    }

    @Test
    func `WHATWG allowed characters remain unencoded`() throws {
        // WHATWG only allows: alphanumeric + *-._
        let input = "abc123*-._"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == input, "WHATWG allowed characters should remain unencoded")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == input, "Foundation should also leave these unencoded")
    }

    // MARK: - Form Data Serialization Differences

    @Test
    func `Form serialization: Complete comparison`() throws {
        let pairs = [
            ("name", "John Doe"),
            ("email", "john@example.com"),
            ("message", "Hello World!")
        ]

        // WHATWG encoding
        let whatwgEncoded = WHATWG_Form_URL_Encoded.serialize(pairs)
        #expect(whatwgEncoded == "name=John+Doe&email=john%40example.com&message=Hello+World%21")

        // Foundation encoding
        var components = URLComponents()
        components.queryItems = pairs.map { URLQueryItem(name: $0.0, value: $0.1) }
        let foundationEncoded = components.percentEncodedQuery

        // Foundation would encode differently (spaces as %20, ! unencoded)
        #expect(foundationEncoded == "name=John%20Doe&email=john@example.com&message=Hello%20World!")

        // They differ
        #expect(whatwgEncoded != foundationEncoded)
    }

    @Test
    func `Plus sign encoding: WHATWG vs Foundation`() throws {
        let input = "a+b"

        // WHATWG: + must be encoded as %2B
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "a%2Bb")

        // Foundation
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "a+b", "Foundation leaves + unencoded in query")
    }

    // MARK: - Edge Cases

    @Test
    func `Empty string: Both handle the same`() throws {
        let input = ""

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery ?? ""
        #expect(foundationEncoded == "")
    }

    @Test
    func `Only spaces: Encoding difference`() throws {
        let input = "   "

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "+++")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%20%20%20")
    }

    @Test
    func `Unicode emoji: Both encode similarly`() throws {
        let input = "🌍"

        // Both should percent-encode UTF-8 bytes
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "%F0%9F%8C%8D")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%F0%9F%8C%8D")
    }

    // MARK: - README Example Verification

    @Test
    func `README example: Hello World! encoding difference`() throws {
        let input = "Hello World!"

        // WHATWG (this package) - from README
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World%21", "Should match README example")

        // Foundation - from README
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World!", "Should match README example")
    }

    // MARK: - Character Set Strictness

    @Test
    func `Decode plus as space`() throws {
        let input = "John+Doe"
        let decoded = try WHATWG_Form_URL_Encoded.PercentEncoding.decode(input, plusAsSpace: true)
        #expect(decoded == "John Doe")
    }

    @Test
    func `WHATWG is stricter: Only alphanumeric + *-._ unencoded`() throws {
        let specialChars = "!@#$^&()+={}[]|\\:;\"'<>?,/~"

        // WHATWG should encode ALL of these
        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(specialChars, spaceAsPlus: true)

        // Should only contain percent-encoded sequences (no literal special chars except %)
        // Check that none of the original special characters appear unencoded
        let unallowedInEncoded = Set(specialChars)
        for char in whatwgEncoded {
            if char != "%" && !char.isHexDigit {
                #expect(!unallowedInEncoded.contains(char), "Unexpected unencoded character '\(char)' in WHATWG output")
            }
        }

        // Foundation is more permissive - it will leave some unencoded
        var components = URLComponents()
        components.query = specialChars
        let foundationEncoded = components.percentEncodedQuery ?? ""

        // Foundation leaves some characters like ! ~ ( ) unencoded
        let permissiveChars = Set("!~()")
        var foundationLeavesUnencoded = false
        for char in permissiveChars {
            if foundationEncoded.contains(char) {
                foundationLeavesUnencoded = true
                break
            }
        }

        #expect(foundationLeavesUnencoded, "Foundation should be more permissive")
    }
}
