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
    /// A URL scheme per WHATWG URL Standard
    ///
    /// Schemes are ASCII strings that identify the type of URL.
    /// Per the standard, schemes are:
    /// - Case-insensitive (normalized to lowercase)
    /// - Must start with ASCII alpha
    /// - Followed by ASCII alphanumeric, +, -, or .
    ///
    /// ## Special Schemes
    ///
    /// Some schemes are "special" and have additional parsing rules:
    /// - ftp, file, http, https, ws, wss
    public struct Scheme: Hashable, Sendable {
        /// The normalized (lowercase) scheme string
        public let value: String

        /// Creates a scheme without validation (for known-valid constants)
        private init(__unchecked: Void, value: String) {
            self.value = value
        }

        /// Creates a scheme with validation and normalization
        ///
        /// Per WHATWG URL Standard, a valid scheme:
        /// - Starts with ASCII alpha
        /// - Followed by ASCII alphanumeric, +, -, or .
        /// - Normalized to lowercase
        ///
        /// - Parameter value: The scheme string to validate
        /// - Throws: `Error` if the scheme is invalid
        public init(_ value: some StringProtocol) throws(Error) {
            guard !value.isEmpty else {
                throw .emptyScheme
            }

            let chars = Array(value.utf8)

            // First character must be ASCII alpha
            guard chars[0].ascii.isLetter else {
                throw .mustStartWithAlpha(Character(UnicodeScalar(chars[0])))
            }

            // Remaining characters must be ASCII alphanumeric, +, -, or .
            for byte in chars.dropFirst() {
                let isValid =
                    byte.ascii.isAlphanumeric || byte == UInt8.ascii.plus
                    || byte == UInt8.ascii.hyphen || byte == UInt8.ascii.period

                guard isValid else {
                    throw .invalidCharacter(Character(UnicodeScalar(byte)))
                }
            }

            self.init(__unchecked: (), value: value.lowercased())
        }
    }
}

// MARK: - Special Schemes

extension WHATWG_URL.URL.Scheme {
    /// Special schemes with their default ports
    private static let specialSchemes: [String: UInt16?] = [
        "ftp": 21,
        "file": nil,
        "http": 80,
        "https": 443,
        "ws": 80,
        "wss": 443,
    ]

    /// Checks if a scheme is a special scheme
    public static func isSpecial(_ scheme: Self) -> Bool {
        specialSchemes.keys.contains(scheme.value)
    }

    /// Returns the default port for a scheme, or nil if not special or has no default port
    public static func defaultPort(for scheme: Self) -> UInt16? {
        specialSchemes[scheme.value] ?? nil
    }
}

// MARK: - Common Schemes (compile-time constants)

extension WHATWG_URL.URL.Scheme {
    public static let http = Self(__unchecked: (), value: "http")
    public static let https = Self(__unchecked: (), value: "https")
    public static let file = Self(__unchecked: (), value: "file")
    public static let ftp = Self(__unchecked: (), value: "ftp")
    public static let ws = Self(__unchecked: (), value: "ws")
    public static let wss = Self(__unchecked: (), value: "wss")
}

// MARK: - ASCII.Serializable ([FAM-012] text sibling)

extension WHATWG_URL.URL.Scheme: ASCII.Serializable {
    /// Serializes the scheme as its lowercase ASCII name (e.g. `http`).
    ///
    /// [FAM-012] text sibling — emits the typed text substrate `ASCII.Code`.
    /// A scheme is **ASCII-only**: the WHATWG URL Standard defines it as an ASCII
    /// string, not an octet wire form, so there is no `Binary.Serializable` peer
    /// (clause-7 — its byte view is a text projection, not a wire codec).
    public static func serialize<Buffer>(
        _ scheme: WHATWG_URL.URL.Scheme,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        for byte in scheme.value.utf8 { buffer.append(ASCII.Code(byte)) }
    }
}

// MARK: - ASCII.Parseable ([FAM-012] parse — free-standing init)

extension WHATWG_URL.URL.Scheme: ASCII.Parseable {
    /// Parses a scheme from ASCII bytes, validating and normalizing to lowercase.
    ///
    /// Delegates to the validating `init(_:)`.
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        try self.init(String(decoding: bytes, as: UTF8.self))
    }
}

// MARK: - CustomStringConvertible

extension WHATWG_URL.URL.Scheme: CustomStringConvertible {
    /// The lowercase scheme name — the same text the `ASCII.Serializable` verb emits.
    ///
    /// Re-provided directly now that the retired deprecated ASCII-into-Byte protocol no
    /// longer supplies the default.
    public var description: String { String(decoding: serialized, as: UTF8.self) }
}
