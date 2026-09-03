public import Byte_Parser_Primitives
public import Parser_Primitives

extension WHATWG_URL.URL.Path {

    public struct Parser: Parser_Primitives.Parser.`Protocol`, Sendable {

        public let context: WHATWG_URL.URL.Path.Context

        public init(_ context: WHATWG_URL.URL.Path.Context) {
            self.context = context
        }
    }
}

extension WHATWG_URL.URL.Path.Parser {
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout ArraySlice<Byte>
    ) throws(WHATWG_URL.URL.Path.Error) -> WHATWG_URL.URL.Path {
        var bytes: [Byte] = []
        while let byte = input.next() {
            bytes.append(byte)
        }
        return try WHATWG_URL.URL.Path(ascii: bytes, in: context)
    }
}

extension WHATWG_URL.URL.Path {

    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes,
        parser: Parser
    ) throws(Error) -> WHATWG_URL.URL.Path
    where Bytes.Element == Byte {
        var input = bytes[...]
        return try parser.parse(&input)
    }
}
