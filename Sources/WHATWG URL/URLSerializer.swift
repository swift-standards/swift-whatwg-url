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
    /// Serializes the URL to its string representation (href)
    ///
    /// The serialization produces an ASCII string where parsing the result
    /// yields an equivalent URL.
    public var href: String {
        var output = ""

        // Scheme
        output += scheme
        output += ":"

        // Authority (host with optional credentials and port)
        if let host = host {
            output += "//"

            // Credentials
            if includesCredentials {
                if !username.isEmpty {
                    output += username
                }
                if !password.isEmpty {
                    output += ":"
                    output += password
                }
                output += "@"
            }

            // Host
            output += host.serialized

            // Port (only if not the default for this scheme)
            if let port = port {
                if URLScheme.defaultPort(for: scheme) != port {
                    output += ":"
                    output += String(port)
                }
            }
        } else if hasOpaquePath {
            // For opaque paths without host
        } else if scheme == "file" {
            // file: URLs always have //
            output += "//"
        }

        // Path
        if hasOpaquePath {
            output += path.serialized
        } else {
            // For list paths, serialization includes leading slash
            output += path.serialized
        }

        // Query
        if let query = query {
            output += "?"
            output += query
        }

        // Fragment
        if let fragment = fragment {
            output += "#"
            output += fragment
        }

        return output
    }

    /// Returns just the origin of the URL
    ///
    /// The origin consists of scheme, host, and port for special schemes.
    /// Returns an opaque origin for non-special schemes.
    public var origin: String {
        guard isSpecial else {
            return "null"
        }

        var output = scheme + "://"

        if let host = host {
            output += host.serialized
        }

        if let port = port, URLScheme.defaultPort(for: scheme) != port {
            output += ":" + String(port)
        }

        return output
    }

    /// Returns the protocol (scheme + ":")
    public var `protocol`: String {
        return scheme + ":"
    }

    /// Returns the host as a string (or empty if nil)
    public var hostname: String {
        return host?.serialized ?? ""
    }

    /// Returns the pathname (path as string)
    public var pathname: String {
        return path.serialized
    }

    /// Returns the search (query with leading "?", or empty if nil)
    public var search: String {
        guard let query = query else { return "" }
        return "?" + query
    }

    /// Returns the hash (fragment with leading "#", or empty if nil)
    public var hash: String {
        guard let fragment = fragment else { return "" }
        return "#" + fragment
    }
}
