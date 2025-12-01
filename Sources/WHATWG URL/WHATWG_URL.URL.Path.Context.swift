//
//  File.swift
//  swift-whatwg-url
//
//  Created by Coen ten Thije Boonkkamp on 01/12/2025.
//

extension WHATWG_URL.URL.Path {
    /// Context for parsing a path
    public struct Context: Sendable {
        /// Whether this is an opaque path (non-special scheme)
        public let isOpaque: Bool
        
        public init(isOpaque: Bool = false) {
            self.isOpaque = isOpaque
        }
    }
}

extension WHATWG_URL.URL.Path.Context {
    
    /// List path context (special schemes)
    public static let list = Self(isOpaque: false)
    
    /// Opaque path context (non-special schemes)
    public static let opaque = Self(isOpaque: true)
}
