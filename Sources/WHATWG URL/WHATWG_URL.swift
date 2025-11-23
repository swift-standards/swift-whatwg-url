//
//  File.swift
//  swift-whatwg-url
//
//  Created by Coen ten Thije Boonkkamp on 23/11/2025.
//

public enum WHATWG_URL {}

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
