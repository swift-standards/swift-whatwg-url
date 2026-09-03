public import Byte_Parser
public import Parser

extension WHATWG_URL.URL {

    public struct Parser: Parser.Parser.`Protocol`, Sendable {

        public let context: WHATWG_URL.URL.ParsingContext

        public init(_ context: WHATWG_URL.URL.ParsingContext) {
            self.context = context
        }
    }
}

extension WHATWG_URL.URL.Parser {
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout ArraySlice<Byte>
    ) throws(WHATWG_URL.URL.Error) -> WHATWG_URL.URL {
        var bytes: [Byte] = []
        while let byte = input.next() {
            bytes.append(byte)
        }
        return try WHATWG_URL.URL(ascii: bytes, in: context)
    }
}

extension WHATWG_URL.URL {

    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes,
        parser: Parser
    ) throws(Error) -> WHATWG_URL.URL
    where Bytes.Element == Byte {
        var input = bytes[...]
        return try parser.parse(&input)
    }
}
