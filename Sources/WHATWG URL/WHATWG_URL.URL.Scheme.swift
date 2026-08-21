public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

extension WHATWG_URL.URL {

    public struct Scheme: Hashable, Sendable {

        public let value: String

        private init(__unchecked: Void, value: String) {
            self.value = value
        }

        public init(_ value: some StringProtocol) throws(Error) {
            guard !value.isEmpty else {
                throw .emptyScheme
            }

            let chars = Array(value.utf8)

            guard chars[0].ascii.isLetter else {
                throw .mustStartWithAlpha(Character(UnicodeScalar(chars[0])))
            }

            for byte in chars.dropFirst() {
                let isValid =
                    byte.ascii.isAlphanumeric || byte == UInt8.ascii.plus
                    || byte == UInt8.ascii.hyphen || byte == UInt8.ascii.period

                guard isValid else {
                    throw .invalidCharacter(Character(UnicodeScalar(byte)))
                }
            }

            self.init(__unchecked: (), value: value.lowercased())
        }
    }
}

extension WHATWG_URL.URL.Scheme {

    private static let specialSchemes: [String: UInt16?] = [
        "ftp": 21,
        "file": nil,
        "http": 80,
        "https": 443,
        "ws": 80,
        "wss": 443,
    ]

    public static func isSpecial(_ scheme: Self) -> Bool {
        specialSchemes.keys.contains(scheme.value)
    }

    public static func defaultPort(for scheme: Self) -> UInt16? {

        specialSchemes[scheme.value].flatMap { $0 }
    }
}

extension WHATWG_URL.URL.Scheme {

    public static let http = Self(__unchecked: (), value: "http")

    public static let https = Self(__unchecked: (), value: "https")

    public static let file = Self(__unchecked: (), value: "file")

    public static let ftp = Self(__unchecked: (), value: "ftp")

    public static let ws = Self(__unchecked: (), value: "ws")

    public static let wss = Self(__unchecked: (), value: "wss")
}

extension WHATWG_URL.URL.Scheme: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ scheme: WHATWG_URL.URL.Scheme,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        for byte in scheme.value.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

extension WHATWG_URL.URL.Scheme: ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let string = String(decoding: bytes, as: UTF8.self)
        try self.init(string)
    }
}

extension WHATWG_URL.URL.Scheme: CustomStringConvertible {

    public var description: String { String(decoding: serialized, as: UTF8.self) }
}
