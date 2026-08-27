import ASCII_Serializer
public import WHATWG_Form_URL_Encoded

extension StringProtocol {

    public static var whatwgURL: WHATWG_URL.StringProtocol<Self>.Type {
        WHATWG_URL.StringProtocol<Self>.self
    }

    public var whatwgURL: WHATWG_URL.StringProtocol<Self> {
        WHATWG_URL.StringProtocol(self)
    }
}

extension String {

    @inlinable
    public init(whatwgURL url: WHATWG_URL.URL) {
        self = url.description
    }

    @inlinable
    public init(whatwgOrigin url: WHATWG_URL.URL) {
        self = url.origin
    }
}

extension WHATWG_URL.StringProtocol {

    @inlinable
    public static func serialize(_ url: WHATWG_URL.URL) -> S {
        S(url.description)!
    }

    @inlinable
    public static func serializeOrigin(_ url: WHATWG_URL.URL) -> S {
        S(url.origin)!
    }
}

extension String {

    @inlinable
    public init(_ host: WHATWG_URL.URL.Host) {
        self = host.description
    }

    @inlinable
    public init(_ path: WHATWG_URL.URL.Path) {
        self = path.description
    }

    @inlinable
    public init(_ searchParams: WHATWG_URL.URL.Search.Params) {
        self = WHATWG_Form_URL_Encoded.serialize(searchParams.entries)
    }
}
