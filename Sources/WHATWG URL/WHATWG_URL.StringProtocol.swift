//
//  WHATWG_URL.StringProtocol.swift
//  swift-whatwg-url
//

extension WHATWG_URL {
    /// Namespace for WHATWG URL string operations
    public struct StringProtocol<S: Swift.StringProtocol> {
        public let value: S

        @usableFromInline
        internal init(_ value: S) {
            self.value = value
        }
    }
}
