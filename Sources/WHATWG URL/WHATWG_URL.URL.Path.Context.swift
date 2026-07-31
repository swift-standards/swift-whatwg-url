//
//  File.swift
//  swift-whatwg-url
//
//  Created by Coen ten Thije Boonkkamp on 01/12/2025.
//

extension WHATWG_URL.URL.Path {
    /// Context for parsing a path
    public struct Context: Sendable {
        /// Whether this is a segment list (special scheme) or an opaque path
        /// (non-special scheme).
        public enum Kind: Sendable, Hashable {
            case list
            case opaque
        }

        public let kind: Kind

        public init(_ kind: Kind = .list) {
            self.kind = kind
        }
    }
}

extension WHATWG_URL.URL.Path.Context {

    /// List path context (special schemes)
    public static let list = Self(.list)

    /// Opaque path context (non-special schemes)
    public static let opaque = Self(.opaque)
}
