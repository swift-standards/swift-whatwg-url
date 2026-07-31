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
    /// Errors that can occur during host parsing
    ///
    /// Per WHATWG URL Standard Section 4.4: Host Parsing
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Invalid domain name
        case invalidDomain(String)

        /// Invalid IPv4 address
        case invalidIPv4Address(String)

        /// Invalid IPv6 address
        case invalidIPv6Address(String)

        /// Invalid opaque host (contains forbidden characters)
        case invalidOpaqueHost(String)

        /// Empty host not allowed in this context
        case emptyHostNotAllowed

        /// Host contains forbidden characters
        case forbiddenHostCodePoint(Character)

        /// IPv6 bracket mismatch
        case ipv6BracketMismatch
    }
}
