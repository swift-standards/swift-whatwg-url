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

extension WHATWG_URL.URL.Host {
    /// Context for parsing a host
    ///
    /// Per WHATWG URL Standard, host parsing behavior differs based on whether
    /// the URL has a "special" scheme (http, https, ftp, file, ws, wss).
    public struct Context: Sendable {
        /// Whether this host is for a special scheme URL
        ///
        /// Special schemes parse hosts as domains (with IDNA).
        /// Non-special schemes parse hosts as opaque strings.
        public enum Kind: Sendable, Hashable {
            case special
            case nonSpecial
        }

        public let kind: Kind

        public init(_ kind: Kind) {
            self.kind = kind
        }
    }
}

extension WHATWG_URL.URL.Host.Context {
    /// Context for special scheme URLs (http, https, etc.)
    public static let special = WHATWG_URL.URL.Host.Context(.special)

    /// Context for non-special scheme URLs
    public static let nonSpecial = WHATWG_URL.URL.Host.Context(.nonSpecial)
}
