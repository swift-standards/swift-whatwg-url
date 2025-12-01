//
//  File.swift
//  swift-whatwg-url
//
//  Created by Coen ten Thije Boonkkamp on 01/12/2025.
//

extension WHATWG_URL.URL.Path {
    /// Errors that can occur during path parsing
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Invalid path segment
        case invalidSegment(String)

        /// Invalid percent encoding in path
        case invalidPercentEncoding(String)
    }
}
