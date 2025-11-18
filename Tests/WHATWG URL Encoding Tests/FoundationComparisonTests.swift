import Testing

@testable import WHATWG_URL_Encoding

/// Tests that compare WHATWG URL encoding against Foundation's URLComponents encoding
///
/// These tests demonstrate the key differences mentioned in the README:
/// 1. Space encoding: WHATWG uses `+`, Foundation uses `%20`
/// 2. Character set: WHATWG only leaves alphanumeric + `*-._` unencoded
/// 3. Specification compliance: WHATWG follows the exact WHATWG algorithm
@Suite("Foundation Comparison Tests")
struct FoundationComparisonTests {

    // MARK: - Space Encoding Differences

    @Test("Space encoding: WHATWG uses + vs Foundation uses %20")
    func spaceEncodingDifference() throws {
        let input = "Hello World"

        // WHATWG encoding (this package)
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World", "WHATWG should encode space as +")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World", "Foundation should encode space as %20")

        // They differ in space encoding
        #expect(whatwgEncoded != foundationEncoded, "WHATWG and Foundation should differ on space encoding")
    }

    @Test("Multiple spaces: WHATWG vs Foundation")
    func multipleSpacesDifference() throws {
        let input = "first second third"

        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "first+second+third")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "first%20second%20third")
    }

    // MARK: - Character Set Differences

    @Test("Exclamation mark: WHATWG encodes, Foundation may not")
    func exclamationMarkDifference() throws {
        let input = "Hello World!"

        // WHATWG encoding
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World%21", "WHATWG should encode ! as %21")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        // Foundation is more permissive - it leaves ! unencoded
        #expect(foundationEncoded == "Hello%20World!", "Foundation leaves ! unencoded")
    }

    @Test("Tilde: WHATWG encodes, Foundation leaves unencoded")
    func tildeDifference() throws {
        let input = "test~value"

        // WHATWG encoding - tilde is NOT in the allowed set (*-._)
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "test%7E" + "value", "WHATWG should encode ~ as %7E")

        // Foundation encoding - more permissive
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "test~value", "Foundation leaves ~ unencoded")
    }

    @Test("Parentheses: WHATWG encodes, Foundation may not")
    func parenthesesDifference() throws {
        let input = "func(arg)"

        // WHATWG encoding
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "func%28arg%29", "WHATWG should encode parentheses")

        // Foundation encoding
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        // Foundation is more permissive
        #expect(foundationEncoded == "func(arg)", "Foundation leaves parentheses unencoded")
    }

    @Test("WHATWG allowed characters remain unencoded")
    func whatwgAllowedCharactersUnencoded() throws {
        // WHATWG only allows: alphanumeric + *-._
        let input = "abc123*-._"

        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == input, "WHATWG allowed characters should remain unencoded")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == input, "Foundation should also leave these unencoded")
    }

    // MARK: - Form Data Serialization Differences

    @Test("Form serialization: Complete comparison")
    func formSerializationComparison() throws {
        let pairs = [
            ("name", "John Doe"),
            ("email", "john@example.com"),
            ("message", "Hello World!")
        ]

        // WHATWG encoding
        let whatwgEncoded = WHATWG_URL_Encoding.serialize(pairs)
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

    @Test("Plus sign encoding: WHATWG vs Foundation")
    func plusSignEncoding() throws {
        let input = "a+b"

        // WHATWG: + must be encoded as %2B
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "a%2Bb")

        // Foundation
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "a+b", "Foundation leaves + unencoded in query")
    }

    // MARK: - Edge Cases

    @Test("Empty string: Both handle the same")
    func emptyStringHandling() throws {
        let input = ""

        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery ?? ""
        #expect(foundationEncoded == "")
    }

    @Test("Only spaces: Encoding difference")
    func onlySpaces() throws {
        let input = "   "

        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "+++")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%20%20%20")
    }

    @Test("Unicode emoji: Both encode similarly")
    func unicodeEmojiEncoding() throws {
        let input = "🌍"

        // Both should percent-encode UTF-8 bytes
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "%F0%9F%8C%8D")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%F0%9F%8C%8D")
    }

    // MARK: - README Example Verification

    @Test("README example: Hello World! encoding difference")
    func readmeExample() throws {
        let input = "Hello World!"

        // WHATWG (this package) - from README
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(input, spaceAsPlus: true)
        #expect(whatwgEncoded == "Hello+World%21", "Should match README example")

        // Foundation - from README
        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World!", "Should match README example")
    }

    // MARK: - Character Set Strictness

    @Test("WHATWG is stricter: Only alphanumeric + *-._ unencoded")
    func whatwgStrictnessVerification() throws {
        let specialChars = "!@#$^&()+={}[]|\\:;\"'<>?,/~"

        // WHATWG should encode ALL of these
        let whatwgEncoded = WHATWG_URL_Encoding.percentEncode(specialChars, spaceAsPlus: true)

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
