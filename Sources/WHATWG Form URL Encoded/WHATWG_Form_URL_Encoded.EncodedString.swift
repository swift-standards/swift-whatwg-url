public import ASCII_Serializer
public import Parseable_ASCII

extension WHATWG_Form_URL_Encoded {

    public struct EncodedString: Hashable, Sendable, CustomStringConvertible {

        public let rawValue: String

        public init(__unchecked rawValue: String) {
            self.rawValue = rawValue
        }

        public init(encoding string: String, space: SpaceEncoding = .plus) {
            self.rawValue = PercentEncoding.encode(string, space: space)
        }
    }
}

extension WHATWG_Form_URL_Encoded.EncodedString {

    public func decoded(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(WHATWG_Form_URL_Encoded.PercentEncoding.Error) -> String {
        try WHATWG_Form_URL_Encoded.PercentEncoding.decode(rawValue, space: space)
    }

    public var description: String {
        rawValue
    }
}

extension WHATWG_Form_URL_Encoded.EncodedString: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ instance: WHATWG_Form_URL_Encoded.EncodedString,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {

        for byte in instance.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

extension WHATWG_Form_URL_Encoded.EncodedString: ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) where Bytes.Element == Byte {

        self.init(__unchecked: String(decoding: bytes, as: UTF8.self))
    }
}

extension WHATWG_Form_URL_Encoded.EncodedString: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {

        self.init(__unchecked: value)
    }
}
