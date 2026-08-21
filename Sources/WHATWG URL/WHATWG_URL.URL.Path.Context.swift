extension WHATWG_URL.URL.Path {

    public struct Context: Sendable {
        public let kind: Kind

        public init(_ kind: Kind = .list) {
            self.kind = kind
        }
    }
}

extension WHATWG_URL.URL.Path.Context {

    public static let list = Self(.list)

    public static let opaque = Self(.opaque)
}
