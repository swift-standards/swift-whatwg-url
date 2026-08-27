public import Byte_Parser
public import Parser

extension WHATWG_URL.URL.Path {

    public struct Parser: Parser.Parser.`Protocol`, Sendable {

        public let context: WHATWG_URL.URL.Path.Context

        public init(_ context: WHATWG_URL.URL.Path.Context) {
            self.context = context
        }
    }
}

extension WHATWG_URL.URL.Path.Parser {
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout Byte.Input
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
        var input = Byte.Input(bytes)
        return try parser.parse(&input)
    }
}
