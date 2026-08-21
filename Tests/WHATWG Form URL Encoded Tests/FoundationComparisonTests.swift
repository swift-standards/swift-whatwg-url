import Foundation
import Testing

@testable import WHATWG_Form_URL_Encoded

@Suite
struct `Foundation Comparison Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Foundation Comparison Tests`.Unit {
    @Test
    func `Decode plus as space`() throws {
        let input = "John+Doe"
        let decoded = try WHATWG_Form_URL_Encoded.PercentEncoding.decode(input, space: .plus)
        #expect(decoded == "John Doe")
    }
}

extension `Foundation Comparison Tests`.`Edge Case` {
    @Test
    func `Empty string: Both handle the same`() throws {
        let input = ""

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded.isEmpty)

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery ?? ""
        #expect(foundationEncoded.isEmpty)
    }

    @Test
    func `Only spaces: Encoding difference`() throws {
        let input = "   "

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "+++")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%20%20%20")
    }

    @Test
    func `Unicode emoji: Both encode similarly`() throws {
        let input = "🌍"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "%F0%9F%8C%8D")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "%F0%9F%8C%8D")
    }
}

extension `Foundation Comparison Tests`.Integration {

    @Test
    func `Space encoding: WHATWG uses + vs Foundation uses %20`() throws {
        let input = "Hello World"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "Hello+World", "WHATWG should encode space as +")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World", "Foundation should encode space as %20")

        #expect(
            whatwgEncoded != foundationEncoded,
            "WHATWG and Foundation should differ on space encoding"
        )
    }

    @Test
    func `Multiple spaces: WHATWG vs Foundation`() throws {
        let input = "first second third"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "first+second+third")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "first%20second%20third")
    }

    @Test
    func `Exclamation mark: WHATWG encodes, Foundation may not`() throws {
        let input = "Hello World!"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "Hello+World%21", "WHATWG should encode ! as %21")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        #expect(foundationEncoded == "Hello%20World!", "Foundation leaves ! unencoded")
    }

    @Test
    func `Tilde: WHATWG encodes, Foundation leaves unencoded`() throws {
        let input = "test~value"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "test%7E" + "value", "WHATWG should encode ~ as %7E")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "test~value", "Foundation leaves ~ unencoded")
    }

    @Test
    func `Parentheses: WHATWG encodes, Foundation may not`() throws {
        let input = "func(arg)"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "func%28arg%29", "WHATWG should encode parentheses")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery

        #expect(foundationEncoded == "func(arg)", "Foundation leaves parentheses unencoded")
    }

    @Test
    func `WHATWG allowed characters remain unencoded`() throws {

        let input = "abc123*-._"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == input, "WHATWG allowed characters should remain unencoded")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == input, "Foundation should also leave these unencoded")
    }

    @Test
    func `Form serialization: Complete comparison`() throws {
        let pairs = [
            ("name", "John Doe"),
            ("email", "john@example.com"),
            ("message", "Hello World!"),
        ]

        let whatwgEncoded = WHATWG_Form_URL_Encoded.serialize(pairs)
        #expect(whatwgEncoded == "name=John+Doe&email=john%40example.com&message=Hello+World%21")

        var components = URLComponents()
        components.queryItems = pairs.map { URLQueryItem(name: $0.0, value: $0.1) }
        let foundationEncoded = components.percentEncodedQuery

        #expect(
            foundationEncoded == "name=John%20Doe&email=john@example.com&message=Hello%20World!"
        )

        #expect(whatwgEncoded != foundationEncoded)
    }

    @Test
    func `Plus sign encoding: WHATWG vs Foundation`() throws {
        let input = "a+b"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "a%2Bb")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "a+b", "Foundation leaves + unencoded in query")
    }

    @Test
    func `README example: Hello World! encoding difference`() throws {
        let input = "Hello World!"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(input, space: .plus)
        #expect(whatwgEncoded == "Hello+World%21", "Should match README example")

        var components = URLComponents()
        components.query = input
        let foundationEncoded = components.percentEncodedQuery
        #expect(foundationEncoded == "Hello%20World!", "Should match README example")
    }

    @Test
    func `WHATWG is stricter: Only alphanumeric + *-._ unencoded`() throws {
        let specialChars = "!@#$^&()+={}[]|\\:;\"'<>?,/~"

        let whatwgEncoded = WHATWG_Form_URL_Encoded.PercentEncoding.encode(
            specialChars,
            space: .plus
        )

        let unallowedInEncoded = Set(specialChars)
        for char in whatwgEncoded {
            if char != "%" && !char.isHexDigit {
                #expect(
                    !unallowedInEncoded.contains(char),
                    "Unexpected unencoded character '\(char)' in WHATWG output"
                )
            }
        }

        var components = URLComponents()
        components.query = specialChars
        let foundationEncoded = components.percentEncodedQuery ?? ""

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
