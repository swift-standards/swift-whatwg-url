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

extension WHATWG_URL {
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

extension WHATWG_URL.Path {
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

    /// Serializes the path to its string representation
    public var serialized: String {
        switch self {
        case .opaque(let segment):
            return segment

        case .list(let segments):
            if segments.isEmpty {
                return ""
            }
            return "/" + segments.joined(separator: "/")
        }
    }

    /// Shortens the path by removing the last segment
    ///
    /// - Parameter scheme: The URL's scheme (for Windows drive letter handling)
    /// - Returns: Whether the path was shortened
    @discardableResult
    public mutating func shorten(scheme: String) -> Bool {
        switch self {
        case .opaque:
            // Cannot shorten opaque paths
            return false

        case .list(var segments):
            // Do not shorten if path is empty
            guard !segments.isEmpty else { return false }

            // Special handling for file: URLs with Windows drive letter
            if scheme == "file" && segments.count == 1 {
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
