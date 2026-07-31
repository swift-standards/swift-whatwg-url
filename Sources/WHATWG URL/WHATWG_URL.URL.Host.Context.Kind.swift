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

extension WHATWG_URL.URL.Host.Context {
    /// Whether this host is for a special scheme URL
    ///
    /// Special schemes parse hosts as domains (with IDNA).
    /// Non-special schemes parse hosts as opaque strings.
    public enum Kind: Sendable, Hashable {
        case special
        case nonSpecial
    }
}
