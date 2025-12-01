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
    /// Errors that can occur during URL parsing
    ///
    /// Per WHATWG URL Standard Section 4.3: Basic URL Parser
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Empty input string
        case emptyInput

        /// Invalid scheme (must start with ASCII alpha, contain only alphanumeric/+/-/.)
        case invalidScheme(String)

        /// Invalid host
        case invalidHost(Host.Error)

        /// Invalid port (must be 0-65535)
        case invalidPort(String)

        /// Invalid path segment
        case invalidPath(String)

        /// Invalid URL structure (missing required components)
        case invalidStructure(String)

        /// Invalid percent encoding in URL
        case invalidPercentEncoding(position: Int, found: String)

        /// Unexpected end of input
        case unexpectedEndOfInput

        /// Cannot have credentials with file scheme or empty host
        case cannotHaveCredentials

        /// Missing scheme separator ":"
        case missingSchemeSeparator
    }
}

// MARK: - Host Errors

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

// MARK: - Scheme Errors

extension WHATWG_URL.URL.Scheme {
    /// Errors that can occur during scheme parsing
    ///
    /// Per WHATWG URL Standard Section 4.3
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Empty scheme
        case emptyScheme

        /// Scheme must start with ASCII alpha
        case mustStartWithAlpha(Character)

        /// Invalid character in scheme (only alphanumeric, +, -, . allowed)
        case invalidCharacter(Character)
    }
}
