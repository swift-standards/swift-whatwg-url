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
    /// A hypertext reference (href) - a normalized, valid URL string
    ///
    /// An `Href` is a newtype wrapper around a String that guarantees:
    /// - The string is a valid URL (parseable per WHATWG URL Standard)
    /// - The string is normalized (serialized per Section 4.5)
    /// - The string represents a complete URL
    ///
    /// ## Type Safety
    ///
    /// This newtype prevents invalid URL strings at compile time:
    ///
    /// ```swift
    /// let href = Href(url)  // Always valid
    /// let href = Href("https://example.com")  // Optional(Href(...)) - validated
    /// let href = Href("not a url")  // nil
    /// ```
    ///
    /// ## Usage in HTML Standard
    ///
    /// This type is used throughout the HTML Standard for elements with href attributes:
    /// - `<a href="...">`
    /// - `<link href="...">`
    /// - `<area href="...">`
    /// - etc.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Invariant**: `value` is always a valid, normalized URL string
    /// - **Construction**: Via total function `Href(URL)` or partial function `Href(String)?`
    /// - **Normalization**: `Href(parse(s)!) == Href(parse(serialize(parse(s)!))!)` (idempotent)
    ///
    /// ## Category Theory
    ///
    /// `Href` forms a quotient type of `String` under URL normalization:
    /// - Equivalence: Two strings are equivalent if they parse to the same URL
    /// - Canonical representative: The normalized (serialized) form
    /// - `Href` selects the canonical representative from each equivalence class
    ///
    /// - SeeAlso: `WHATWG_URL.Serialization.serialize(_:)`
    public struct Href: Hashable, Sendable {
        /// The normalized, valid URL string
        public let value: String

        /// Creates an Href from a URL
        ///
        /// This is a **total function** - always succeeds.
        ///
        /// - Parameter url: The URL to serialize as an href
        public init(_ url: WHATWG_URL.URL) {
            self.value = WHATWG_URL.Serialization.serialize(url)
        }

        /// Creates an Href by parsing and normalizing a string
        ///
        /// This is a **partial function** - returns nil if the string is not a valid URL.
        ///
        /// ## Normalization
        ///
        /// If successful, the resulting Href contains the **normalized** form:
        /// ```swift
        /// let h1 = Href("HTTPS://EXAMPLE.COM/PATH")
        /// let h2 = Href("https://example.com/PATH")
        /// // h1?.value == h2?.value (both normalized to lowercase scheme/host)
        /// ```
        ///
        /// ## Implementation Status
        ///
        /// ⚠️ **TODO**: This currently uses a stub parser that always returns nil.
        ///
        /// To properly implement this, we need `WHATWG_URL.Parser.parse` which implements
        /// the WHATWG URL Basic URL Parser (Section 4.3). This is a complex state machine
        /// that handles validation, normalization, and percent-encoding.
        ///
        /// - Parameter string: The string to parse as a URL
        /// - Returns: Validated, normalized Href, or nil if invalid
        public init?(_ string: some StringProtocol) {
            // Parse the string into a URL
            guard let url = WHATWG_URL.Parser.parse(string) else {
                return nil
            }

            // Serialize the URL to get normalized form
            self.init(url)
        }

        /// Creates an Href without validation (for known-valid strings)
        ///
        /// - Warning: Only use this when you have a string that you **know** is already
        ///           a valid, normalized URL (e.g., from trusted sources or serialization).
        ///
        /// - Parameter value: Pre-validated, normalized URL string
        internal init(unchecked value: String) {
            self.value = value
        }
    }
}

// MARK: - String Conversion

extension String {
    /// Creates a string from an Href
    ///
    /// - Parameter href: The Href to convert
    public init(_ href: WHATWG_URL.URL.Href) {
        self = href.value
    }
}

// MARK: - CustomStringConvertible

extension WHATWG_URL.URL.Href: CustomStringConvertible {
    public var description: String {
        value
    }
}

// MARK: - ExpressibleByStringLiteral (for testing/convenience)

extension WHATWG_URL.URL.Href: ExpressibleByStringLiteral {
    /// Creates an Href from a string literal
    ///
    /// - Warning: This will **trap** if the literal is not a valid URL.
    ///           Only use with string literals you know are valid.
    ///           For runtime strings, use `init?(_ string:)` instead.
    ///
    /// ```swift
    /// let href: Href = "https://example.com"  // ✓ Compiles, valid
    /// let href: Href = "not a url"  // ✗ Traps at runtime!
    /// ```
    public init(stringLiteral value: String) {
        guard let href = Self(value) else {
            preconditionFailure("Invalid URL literal: \(value)")
        }
        self = href
    }
}

// MARK: - Equatable with String (for ergonomic comparisons)

extension WHATWG_URL.URL.Href: Equatable {
    /// Compares two Hrefs for equality
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    /// Compares Href with String for equality
    ///
    /// This allows ergonomic comparisons in tests and code:
    /// ```swift
    /// let href = url.href
    /// if href == "https://example.com" { ... }
    /// ```
    public static func == (lhs: Self, rhs: String) -> Bool {
        lhs.value == rhs
    }

    /// Compares String with Href for equality (symmetric)
    public static func == (lhs: String, rhs: Self) -> Bool {
        lhs == rhs.value
    }
}
