// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

import WHATWG_Form_URL_Encoded

/// URLSearchParams provides utilities for working with URL query strings
///
/// This type wraps the WHATWG Form URL Encoded functionality to provide
/// a convenient API for parsing and serializing URL search parameters.
///
/// ## Example
///
/// ```swift
/// // Parse query string
/// let params = URLSearchParams("name=John+Doe&email=john%40example.com")
/// print(params.get("name"))  // Optional("John Doe")
///
/// // Build query string
/// var params = URLSearchParams()
/// params.append("name", "John Doe")
/// params.append("email", "john@example.com")
/// print(params.toString())  // "name=John+Doe&email=john%40example.com"
/// ```
public struct URLSearchParams {
    private var pairs: [(String, String)]

    /// Creates an empty URLSearchParams
    public init() {
        self.pairs = []
    }

    /// Creates URLSearchParams by parsing a query string
    ///
    /// - Parameter query: The query string (with or without leading "?")
    public init(_ query: String) {
        let cleaned = query.hasPrefix("?") ? String(query.dropFirst()) : query
        self.pairs = WHATWG_Form_URL_Encoded.parse(cleaned)
    }

    /// Creates URLSearchParams from name-value pairs
    public init(_ pairs: [(String, String)]) {
        self.pairs = pairs
    }

    /// Appends a new name-value pair
    public mutating func append(_ name: String, _ value: String) {
        pairs.append((name, value))
    }

    /// Deletes all name-value pairs with the given name
    public mutating func delete(_ name: String) {
        pairs.removeAll { $0.0 == name }
    }

    /// Returns the first value associated with the given name
    public func get(_ name: String) -> String? {
        return pairs.first { $0.0 == name }?.1
    }

    /// Returns all values associated with the given name
    public func getAll(_ name: String) -> [String] {
        return pairs.filter { $0.0 == name }.map { $0.1 }
    }

    /// Checks if a name exists
    public func has(_ name: String) -> Bool {
        return pairs.contains { $0.0 == name }
    }

    /// Sets the value for the given name, replacing all existing values
    public mutating func set(_ name: String, _ value: String) {
        // Remove all existing pairs with this name
        pairs.removeAll { $0.0 == name }
        // Add the new pair
        pairs.append((name, value))
    }

    /// Sorts all name-value pairs by their names
    public mutating func sort() {
        pairs.sort { $0.0 < $1.0 }
    }

    /// Returns the query string representation
    public func toString() -> String {
        return WHATWG_Form_URL_Encoded.serialize(pairs)
    }

    /// Returns all name-value pairs
    public var entries: [(String, String)] {
        return pairs
    }

    /// Returns the number of name-value pairs
    public var count: Int {
        return pairs.count
    }

    /// Returns whether there are no pairs
    public var isEmpty: Bool {
        return pairs.isEmpty
    }
}

extension URLSearchParams: Sequence {
    public func makeIterator() -> IndexingIterator<[(String, String)]> {
        return pairs.makeIterator()
    }
}

extension URLSearchParams: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.pairs = elements
    }
}

extension URLSearchParams: CustomStringConvertible {
    public var description: String {
        return toString()
    }
}
