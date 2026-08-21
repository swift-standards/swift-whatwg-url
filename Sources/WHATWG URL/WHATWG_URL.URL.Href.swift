public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

extension WHATWG_URL.URL {

    public struct Href: Hashable, Sendable {

        public let value: String

        private init(__unchecked: Void, value: String) {
            self.value = value
        }

        public init(_ url: WHATWG_URL.URL) {

            self.init(__unchecked: (), value: url.description)
        }
    }
}

extension WHATWG_URL.URL.Href: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ href: WHATWG_URL.URL.Href,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        for byte in href.value.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

extension WHATWG_URL.URL.Href: ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(WHATWG_URL.URL.Error)
    where Bytes.Element == Byte {
        let url = try WHATWG_URL.URL(ascii: bytes, in: .none)
        self.init(url)
    }
}

extension WHATWG_URL.URL.Href: CustomStringConvertible {

    public var description: String { String(decoding: serialized, as: UTF8.self) }
}
