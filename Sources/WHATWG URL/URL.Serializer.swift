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
    /// Returns the hypertext reference (href) - the normalized, serialized URL
    ///
    /// Pure delegation to authoritative implementation via `Href(url)`.
    ///
    /// ## Purpose
    ///
    /// This property provides the canonical, type-safe representation of the serialized URL.
    /// Per WHATWG URL Standard Section 4.5, the serialization produces an ASCII string
    /// where parsing the result yields an equivalent URL.
    ///
    /// ## Type Safety
    ///
    /// Returns `Href` (not `String`) to guarantee the result is a valid, normalized URL.
    /// This prevents mixing arbitrary strings with URL references:
    ///
    /// ```swift
    /// let href: Href = url.href        // Type-safe ✓
    /// let string: String = String(href)  // Explicit conversion when needed
    /// ```
    ///
    /// ## Usage Pattern
    ///
    /// For structured access to URL components, use the type-safe properties:
    /// - `url.scheme` → `Scheme` (type-safe)
    /// - `url.host` → `Host?` (type-safe)
    /// - `url.path` → `Path` (type-safe)
    /// - `url.query` → `String?`
    /// - `url.fragment` → `String?`
    ///
    /// Use `href` when you need the complete serialized URL as a validated, normalized reference.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Always produces a valid Href
    /// - **Determinism**: Same URL always produces same Href
    /// - **Idempotence**: `parse(url.href.value).href == url.href` (round-trip property)
    /// - **Normalization**: Result is the canonical representative of the URL's equivalence class
    ///
    /// - Returns: Type-safe Href (e.g., `Href("https://example.com:8080/path?query#fragment")`)
    public var href: Href {
        Href(self)
    }

    /// Returns the origin of the URL
    ///
    /// Pure delegation to authoritative implementation `WHATWG_URL.Serialization.serializeOrigin`.
    ///
    /// ## Purpose
    ///
    /// The origin is used for security checks in web contexts (same-origin policy).
    /// Per WHATWG URL Standard Section 4.7:
    /// - For special schemes: scheme + "://" + host + port (if non-default)
    /// - For non-special schemes: "null" (opaque origin)
    ///
    /// ## Security Properties
    ///
    /// - Origins partition URLs into equivalence classes
    /// - Two URLs with same origin can access each other's resources
    /// - Opaque origins ("null") never match any origin, including themselves
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Always produces a valid String
    /// - **Non-injectivity**: Different URLs may have same origin
    /// - **Equivalence relation**: Defines same-origin equivalence classes
    ///
    /// - Returns: Origin string (e.g., "https://example.com:8080") or "null"
    public var origin: String {
        WHATWG_URL.Serialization.serializeOrigin(self)
    }
}
