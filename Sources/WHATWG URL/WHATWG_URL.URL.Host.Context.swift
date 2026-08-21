extension WHATWG_URL.URL.Host {

    public struct Context: Sendable {
        public let kind: Kind

        public init(_ kind: Kind) {
            self.kind = kind
        }
    }
}

extension WHATWG_URL.URL.Host.Context {

    public static let special = WHATWG_URL.URL.Host.Context(.special)

    public static let nonSpecial = WHATWG_URL.URL.Host.Context(.nonSpecial)
}
