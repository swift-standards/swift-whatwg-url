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
    /// URL scheme utilities per WHATWG URL Standard
    public enum Scheme {
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
        public static func isSpecial(_ scheme: String) -> Bool {
            return specialSchemes.keys.contains(scheme)
        }

        /// Returns the default port for a special scheme, or nil if not a special scheme or has no default port
        public static func defaultPort(for scheme: String) -> UInt16? {
            return specialSchemes[scheme] ?? nil
        }

        /// Checks if a scheme is valid (starts with ASCII alpha, followed by ASCII alphanumeric, +, -, or .)
        public static func isValid(_ scheme: String) -> Bool {
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
}
