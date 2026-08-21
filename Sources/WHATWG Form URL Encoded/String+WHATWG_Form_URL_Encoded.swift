import RFC_4648

extension WHATWG_Form_URL_Encoded {

    public struct FormURLEncoded<S: StringProtocol> {
        public let value: S

        @usableFromInline
        internal init(_ value: S) {
            self.value = value
        }
    }
}

extension StringProtocol {

    public static var formURL: WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.Type {
        WHATWG_Form_URL_Encoded.FormURLEncoded<Self>.self
    }

    public var formURL: WHATWG_Form_URL_Encoded.FormURLEncoded<Self> {
        WHATWG_Form_URL_Encoded.FormURLEncoded(self)
    }
}

extension StringProtocol {

    @inlinable
    public init(
        formURLEncoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        self = Self.formURL.encode(string, space: space)
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncoded {

    @inlinable
    public static func encode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> S {
        S(WHATWG_Form_URL_Encoded.PercentEncoding.encode(String(string), space: space))!
    }

    @inlinable
    public func encoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S {
        Self.encode(self.value, space: space)
    }

    @inlinable
    public func callAsFunction(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S {
        encoded(space: space)
    }
}

extension StringProtocol {

    @inlinable
    public init?(
        formURLDecoding string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        guard let decoded = Self.formURL.decode(string, space: space) else {
            return nil
        }
        self = decoded
    }
}

extension WHATWG_Form_URL_Encoded.FormURLEncoded {

    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> S? {
        guard
            let decoded = WHATWG_Form_URL_Encoded.PercentEncoding.decodeOrNil(
                String(string),
                space: space
            )
        else {
            return nil
        }
        return S(decoded)
    }

    @inlinable
    public func decoded(space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus) -> S? {
        Self.decode(self.value, space: space)
    }
}

extension String {

    @inlinable
    public init(
        formURLEncodingBytes bytes: [UInt8],
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) {
        let decoded = String(decoding: bytes, as: UTF8.self)
        self = WHATWG_Form_URL_Encoded.PercentEncoding.encode(decoded, space: space)
    }
}

extension String {

    public func formURLEncodedString(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> WHATWG_Form_URL_Encoded.EncodedString {
        WHATWG_Form_URL_Encoded.EncodedString(encoding: self, space: space)
    }

    public func decodingFormURLEncoded(
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(WHATWG_Form_URL_Encoded.PercentEncoding.Error) -> String {
        try WHATWG_Form_URL_Encoded.PercentEncoding.decode(self, space: space)
    }
}
