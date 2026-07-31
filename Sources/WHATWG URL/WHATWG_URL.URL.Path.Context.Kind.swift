//
//  WHATWG_URL.URL.Path.Context.Kind.swift
//  swift-whatwg-url
//
//  Created by Coen ten Thije Boonkkamp on 01/12/2025.
//

extension WHATWG_URL.URL.Path.Context {
    /// Whether this is a segment list (special scheme) or an opaque path
    /// (non-special scheme).
    public enum Kind: Sendable, Hashable {
        case list
        case opaque
    }
}
