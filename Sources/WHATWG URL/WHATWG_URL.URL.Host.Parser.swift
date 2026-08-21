public import Byte_Parser_Primitives
public import Parser_Primitives

extension WHATWG_URL.URL.Host {

    public struct Parser: Parser_Primitives.Parser.`Protocol`, Sendable {

        public let context: WHATWG_URL.URL.Host.Context

        public init(_ context: WHATWG_URL.URL.Host.Context) {
            self.context = context
        }
    }
}

extension WHATWG_URL.URL.Host.Parser {
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout Byte.Input
    ) throws(WHATWG_URL.URL.Host.Error) -> WHATWG_URL.URL.Host {
        var bytes: [Byte] = []
        while let byte = input.next() {
            bytes.append(byte)
        }
        return try WHATWG_URL.URL.Host(ascii: bytes, in: context)
    }
}

extension WHATWG_URL.URL.Host {

    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes,
        parser: Parser
    ) throws(Error) -> WHATWG_URL.URL.Host
    where Bytes.Element == Byte {
        var input = Byte.Input(bytes)
        return try parser.parse(&input)
    }
}
