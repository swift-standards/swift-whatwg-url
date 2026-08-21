extension WHATWG_URL {

    public struct StringProtocol<S: Swift.StringProtocol> {
        public let value: S

        @usableFromInline
        internal init(_ value: S) {
            self.value = value
        }
    }
}
