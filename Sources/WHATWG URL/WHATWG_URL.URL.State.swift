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
    /// Parser states for the URL parsing state machine
    enum State {
        case schemeStart
        case scheme
        case noScheme
        case specialAuthoritySlashes
        case pathOrAuthority
        case authority
        case host
        case port
        case pathStart
        case path
        case relativePath
        case opaquePath
        case query
        case fragment
    }
}
