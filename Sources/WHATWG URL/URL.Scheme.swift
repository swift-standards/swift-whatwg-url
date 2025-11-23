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
    ///
    /// ## Type Safety
    ///
    /// This newtype prevents invalid schemes at compile time and ensures
    /// normalization (lowercasing) happens at construction.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let scheme = WHATWG_URL.URL.Scheme("HTTPS")  // Optional(Scheme("https"))
    /// let invalid = WHATWG_URL.URL.Scheme("123")   // nil
    /// ```
    public struct Scheme: Hashable, Sendable {
        /// The normalized (lowercase) scheme string
        public let value: String

        /// Creates a scheme from a string with validation and normalization
        ///
        /// - Parameter value: The scheme string to validate
        /// - Returns: Validated, normalized scheme, or nil if invalid
        public init?(_ value: some StringProtocol) {
            guard Self.isValid(value) else { return nil }
            self.value = value.lowercased()
        }

        /// Creates a scheme without validation (for known-valid constants)
        ///
        /// - Parameter value: Pre-validated, lowercase scheme string
        internal init(unchecked value: String) {
            self.value = value
        }
    }
}

// MARK: - Scheme Validation

extension WHATWG_URL.URL.Scheme {
    /// Checks if a scheme string is valid
    ///
    /// Per WHATWG URL Standard, a valid scheme:
    /// - Starts with ASCII alpha
    /// - Followed by ASCII alphanumeric, +, -, or .
    ///
    /// - Parameter scheme: The scheme string to validate
    /// - Returns: Whether the scheme is valid
    public static func isValid(_ scheme: some StringProtocol) -> Bool {
        guard !scheme.isEmpty else { return false }
        let chars = Array(scheme)

        // First character must be ASCII alpha
        guard chars[0].isASCII && chars[0].isLetter else {
            return false
        }

        // Remaining characters must be ASCII alphanumeric, +, -, or .
        for char in chars.dropFirst() {
            guard char.isASCII else { return false }
            guard char.isLetter || char.isNumber || char == "+" || char == "-" || char == "." else {
                return false
            }
        }

        return true
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
        "wss": 443
    ]

    /// Checks if a scheme is a special scheme
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Total function - defined for all Scheme values
    /// - **Determinism**: Same scheme always returns same boolean
    /// - **Decidability**: O(1) lookup in constant-size table
    ///
    /// - Parameter scheme: The scheme to check
    /// - Returns: Whether the scheme is special
    public static func isSpecial(_ scheme: Self) -> Bool {
        specialSchemes.keys.contains(scheme.value)
    }

    /// Returns the default port for a scheme, or nil if not special or has no default port
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Total function - defined for all Scheme values
    /// - **Partiality of Result**: May return nil (not all schemes have default ports)
    /// - **Specification**: Per WHATWG URL Standard Section 4.2
    ///
    /// - Parameter scheme: The scheme to query
    /// - Returns: Default port, or nil
    public static func defaultPort(for scheme: Self) -> UInt16? {
        specialSchemes[scheme.value] ?? nil
    }
}

// MARK: - Common Schemes

extension WHATWG_URL.URL.Scheme {
    public static let http = Self(unchecked: "http")
    public static let https = Self(unchecked: "https")
    public static let file = Self(unchecked: "file")
    public static let ftp = Self(unchecked: "ftp")
    public static let ws = Self(unchecked: "ws")
    public static let wss = Self(unchecked: "wss")
}

// MARK: - String Conversion

extension String {
    /// Creates a string from a URL scheme
    ///
    /// - Parameter scheme: The scheme to convert
    public init(_ scheme: WHATWG_URL.URL.Scheme) {
        self = scheme.value
    }
}

// MARK: - ExpressibleByStringLiteral (for testing/convenience)

extension WHATWG_URL.URL.Scheme: ExpressibleByStringLiteral {
    /// Creates a Scheme from a string literal
    ///
    /// - Warning: This will **trap** if the literal is not a valid scheme.
    ///           Only use with string literals you know are valid.
    ///           For runtime strings, use `init?(_ value:)` instead.
    ///
    /// ```swift
    /// let scheme: Scheme = "https"  // ✓ Compiles, valid
    /// let scheme: Scheme = "123"    // ✗ Traps at runtime!
    /// ```
    public init(stringLiteral value: String) {
        guard let scheme = Self(value) else {
            preconditionFailure("Invalid scheme literal: \(value)")
        }
        self = scheme
    }
}
