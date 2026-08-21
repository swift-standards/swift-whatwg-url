import RFC_4648

extension WHATWG_Form_URL_Encoded {

    public struct FormURLEncodedBytes {
        public let bytes: [UInt8]

        @usableFromInline
        internal init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}

extension [UInt8] {

    public static var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncodedBytes.Type {
        WHATWG_Form_URL_Encoded.FormURLEncodedBytes.self
    }

    public var formURLEncoded: WHATWG_Form_URL_Encoded.FormURLEncodedBytes {
        WHATWG_Form_URL_Encoded.FormURLEncodedBytes(bytes: self)
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncodedBytes {

    @inlinable
    public func encoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> String {
        WHATWG_Form_URL_Encoded.PercentEncoding.encode(
            String(decoding: self.bytes, as: UTF8.self),
            space: space
        )
    }

    @inlinable
    public func callAsFunction(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> String {
        encoded(space: space)
    }
}

extension [UInt8] {

    @inlinable
    public init?(
        formURLDecoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        guard let decoded = Self.formURLEncoded.decode(string, space: space) else {
            return nil
        }
        self = decoded
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncodedBytes {

    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> [UInt8]? {
        guard
            let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decodeOrNil(
                String(string),
                space: space
            )
        else {
            return nil
        }
        return Array(decoded.utf8)
    }
}
