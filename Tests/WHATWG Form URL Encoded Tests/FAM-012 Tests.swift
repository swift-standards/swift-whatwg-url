import ASCII_Serializer
import Testing

@testable import WHATWG_Form_URL_Encoded

extension WHATWG_Form_URL_Encoded.EncodedString {
    @Suite("WHATWG Form URL Encoded [FAM-012] Format Siblings")
    struct Test {

        @Test func `EncodedString ASCII serialize + parse round-trip`() throws {
            let encoded = WHATWG_Form_URL_Encoded.EncodedString(encoding: "Hello World!")
            #expect(encoded.description == "Hello+World%21")

            var codes: [ASCII.Code] = []
            WHATWG_Form_URL_Encoded.EncodedString.serialize(encoded, into: &codes)
            #expect(String(decoding: codes.map(\.byte), as: UTF8.self) == "Hello+World%21")

            let reparsed = WHATWG_Form_URL_Encoded.EncodedString(ascii: codes.map(\.byte))
            #expect(reparsed == encoded)
            #expect(reparsed.description == "Hello+World%21")
        }
    }
}
