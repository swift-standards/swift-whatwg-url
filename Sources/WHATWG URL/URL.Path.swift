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

extension WHATWG_URL.URL {
    /// A URL path as defined by the WHATWG URL Standard
    ///
    /// A URL's path is either a URL path segment (opaque path) or a list of zero or more URL path segments.
    /// A URL path segment is an ASCII string.
    public enum Path: Hashable, Sendable {
        /// An opaque path (single string) used for non-special URLs
        case opaque(String)

        /// A list of path segments (used for special URLs like http, https, file, etc.)
        case list([String])
    }
}



extension WHATWG_URL.URL.Path {
    /// Returns an empty list path
    public static var emptyList: Self {
        .list([])
    }

    /// Returns an empty opaque path
    public static var emptyOpaque: Self {
        .opaque("")
    }

    /// Whether this path is empty
    public var isEmpty: Bool {
        switch self {
        case .opaque(let segment):
            return segment.isEmpty
        case .list(let segments):
            return segments.isEmpty
        }
    }

    /// Shortens the path by removing the last segment
    ///
    /// ## Mathematical Properties
    ///
    /// - **Partiality**: May return false (cannot shorten further)
    /// - **Idempotence**: `shorten()` followed by `shorten()` behaves as expected (removes two segments)
    /// - **Monotonicity**: Path becomes shorter or stays same length (never grows)
    /// - **Invariants**:
    ///   - Opaque paths cannot be shortened
    ///   - file: URLs preserve Windows drive letters (C:, D:, etc.)
    ///   - Empty list paths cannot be shortened
    ///
    /// ## Category Theory
    ///
    /// This is a destructive morphism in the category of paths:
    /// - **Nature**: Partial endomorphism on Path
    /// - **Effect**: Path → Path' where |Path'| ≤ |Path|
    /// - **Inverse**: No unique inverse (information is lost)
    ///
    /// - Parameter scheme: The URL's scheme (for Windows drive letter handling)
    /// - Returns: Whether the path was shortened
    @discardableResult
    public mutating func shorten(scheme: WHATWG_URL.URL.Scheme) -> Bool {
        switch self {
        case .opaque:
            // Cannot shorten opaque paths
            return false

        case .list(var segments):
            // Do not shorten if path is empty
            guard !segments.isEmpty else { return false }

            // Special handling for file: URLs with Windows drive letter
            if scheme.value == "file" && segments.count == 1 {
                if let first = segments.first, isWindowsDriveLetter(first) {
                    return false
                }
            }

            segments.removeLast()
            self = .list(segments)
            return true
        }
    }

    /// Appends a segment to the path
    ///
    /// ## Mathematical Properties
    ///
    /// - **Partiality**: No-op for opaque paths (they cannot be appended to)
    /// - **Effect**: For list paths, increases length by 1
    /// - **Associativity**: `(p.append(a)).append(b)` ≡ sequence of appends
    /// - **Inverse**: `shorten()` is the partial inverse of `append()`
    ///
    /// ## Category Theory
    ///
    /// This is a constructive morphism in the category of paths:
    /// - **Nature**: Partial endomorphism on Path
    /// - **Effect**: Path → Path' where |Path'| = |Path| + 1 (for list paths)
    /// - **Monoid**: List paths with append form a monoid (identity = empty list)
    ///
    public mutating func append(_ segment: String) {
        switch self {
        case .opaque:
            // Cannot append to opaque paths
            break

        case .list(var segments):
            segments.append(segment)
            self = .list(segments)
        }
    }

    /// Checks if a string is a Windows drive letter (e.g., "C:" or "C|")
    private func isWindowsDriveLetter(_ string: String) -> Bool {
        guard string.count == 2 else { return false }
        let chars = Array(string)
        guard chars[0].isLetter else { return false }
        return chars[1] == ":" || chars[1] == "|"
    }
}

// MARK: - Path Serialization

extension WHATWG_URL.URL.Path {
    /// Serializes a path to its string representation
    ///
    /// This is the authoritative implementation per WHATWG URL Standard Section 4.3.
    ///
    /// ## Serialization Rules
    ///
    /// - **Opaque path**: Serialized as-is (percent-encoded string)
    /// - **List path**: Serialized as "/" + segments joined by "/"
    /// - **Empty list**: Serialized as "" (no leading slash)
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: This function is total - always produces a String
    /// - **Injectivity**: Different paths produce different strings (up to normalization)
    /// - **Determinism**: Same path always produces same string
    ///
    /// - Parameter path: The path to serialize
    /// - Returns: String representation of the path
    public static func serialize(_ path: Self) -> String {
        switch path {
        case .opaque(let segment):
            // Opaque path: single percent-encoded string
            return segment

        case .list(let segments):
            // List path: segments joined by "/"
            if segments.isEmpty {
                return ""
            }
            return "/" + segments.joined(separator: "/")
        }
    }
}
