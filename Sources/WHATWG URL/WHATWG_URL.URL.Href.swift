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

public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

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
    /// This newtype prevents invalid URL strings at compile time.
    /// Construction is only possible from a valid `WHATWG_URL.URL`.
    public struct Href: Hashable, Sendable {
        /// The normalized, valid URL string
        public let value: String

        /// Creates an Href without validation (for known-valid strings)
        private init(__unchecked: Void, value: String) {
            self.value = value
        }

        /// Creates an Href from a validated URL
        ///
        /// This is the core initializer - always succeeds because the URL is already valid.
        /// Uses the URL's `ASCII.Serializable` verb (via `description`) to serialize
        /// the URL to its canonical form.
        public init(_ url: WHATWG_URL.URL) {
            // swift-linter:disable:next unchecked call site
            // REASON: extension-init internals — same-package construction of the wrapper's
            // own boundary, permitted use per [CONV-001].
            self.init(__unchecked: (), value: url.description)
        }
    }
}

// MARK: - ASCII.Serializable ([FAM-012] text sibling)

extension WHATWG_URL.URL.Href: ASCII.Serializable {
    /// Serializes the href as its canonical URL text.
    ///
    /// [FAM-012] text sibling — emits the typed text substrate `ASCII.Code`.
    /// An href is **ASCII-only**: it is a normalized URL string (WHATWG §4.5),
    /// not an octet wire form, so there is no `Binary.Serializable` peer.
    public static func serialize<Buffer>(
        _ href: WHATWG_URL.URL.Href,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        for byte in href.value.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

// MARK: - ASCII.Parseable ([FAM-012] parse — free-standing init)

extension WHATWG_URL.URL.Href: ASCII.Parseable {
    /// Parses an href from ASCII bytes: parses the bytes as a URL, then wraps it.
    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(WHATWG_URL.URL.Error)
    where Bytes.Element == Byte {
        let url = try WHATWG_URL.URL(ascii: bytes, in: .none)
        self.init(url)
    }
}

// MARK: - CustomStringConvertible

extension WHATWG_URL.URL.Href: CustomStringConvertible {
    /// The canonical URL text — the same the `ASCII.Serializable` verb emits.
    public var description: String { String(decoding: serialized, as: UTF8.self) }
}
