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
