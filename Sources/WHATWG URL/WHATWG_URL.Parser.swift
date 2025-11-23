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

import Foundation
import RFC_791
import RFC_4291
import Domain_Standard

extension WHATWG_URL {
    /// URL Parsing (Section 4.3)
    ///
    /// Authoritative implementations for parsing URLs from strings.
    ///
    /// Per WHATWG URL Standard Section 4.3, URL parsing is the inverse operation
    /// of serialization, producing a URL from an ASCII string.
    ///
    /// ## Architecture
    ///
    /// Like serialization, parsing follows a primitive → composition architecture:
    ///
    /// ### Level 1: Primitive Parsers
    /// - `Scheme.parse(String) → Scheme?`
    /// - `Host.parse(String) → Host?`
    /// - `Path.parse(String) → Path`
    /// - `Port.parse(String) → UInt16?`
    /// - Query/Fragment (already strings, just extract)
    ///
    /// ### Level 2: Composed Parser
    /// - `Parser.parse(String, base: URL?) → URL?`
    ///   Implements WHATWG URL Standard Basic URL Parser (Section 4.3)
    ///   Composes primitive parsers with state machine
    ///
    /// ### Level 3: Convenience APIs
    /// - `URL.init?(_ string: String)`
    /// - `Href.init?(_ string: String)`
    ///
    /// ## Implementation Status
    ///
    /// ⚠️ **TODO**: This parser is not yet implemented.
    ///
    /// The WHATWG URL parser is a complex state machine with ~15 states:
    /// - Scheme start, scheme, no scheme
    /// - File, file slash, file host
    /// - Authority, host, hostname, port
    /// - Path start, path, cannot-be-a-base-URL path
    /// - Query, fragment
    ///
    /// Each state has specific rules for character processing, validation,
    /// percent-encoding, and state transitions.
    ///
    /// ## Specification Reference
    ///
    /// WHATWG URL Standard Section 4.3 - Basic URL Parser:
    /// https://url.spec.whatwg.org/#url-parsing
    ///
    /// ## Mathematical Properties (when implemented)
    ///
    /// - **Partiality**: `parse: String ⇀ URL` (partial function - not all strings are valid URLs)
    /// - **Left inverse of serialize**: `parse(serialize(url)) = url` (modulo normalization)
    /// - **Not right inverse**: `serialize(parse(s)) ≠ s` in general (normalization changes string)
    /// - **Idempotence**: `parse(serialize(parse(s))) = parse(s)` (normalize then parse is stable)
    ///
    /// ## Category Theory (when implemented)
    ///
    /// - **Parse**: Partial morphism `String ⇀ URL`
    /// - **Serialize**: Total morphism `URL → String`
    /// - **Relationship**: Adjunction where parse is left adjoint to serialize
    /// - **Normalization**: Quotient by equivalence relation on strings
    public enum Parser {}
}

// MARK: - Parser State Machine

extension WHATWG_URL.Parser {
    /// Parser states for the URL parsing state machine
    fileprivate enum State {
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

// MARK: - URL Builder

extension WHATWG_URL.Parser {
    /// Internal builder for constructing URLs during parsing
    fileprivate struct URLBuilder {
        var scheme: WHATWG_URL.URL.Scheme?
        var username: String?
        var password: String?
        var host: WHATWG_URL.URL.Host?
        var port: UInt16?
        var path: WHATWG_URL.URL.Path = .list([])
        var query: String?
        var fragment: String?

        mutating func pushPathSegment(_ segment: String) {
            switch path {
            case .list(var segments):
                segments.append(segment)
                path = .list(segments)
            case .opaque:
                // Can't push to opaque path
                break
            }
        }

        mutating func popPathSegment() {
            switch path {
            case .list(var segments):
                if !segments.isEmpty {
                    segments.removeLast()
                }
                path = .list(segments)
            case .opaque:
                // Can't pop from opaque path
                break
            }
        }

        func build() -> WHATWG_URL.URL? {
            guard let scheme = scheme else {
                return nil
            }

            return WHATWG_URL.URL(
                scheme: scheme,
                username: username ?? "",
                password: password ?? "",
                host: host,
                port: port,
                path: path,
                query: query,
                fragment: fragment
            )
        }
    }
}

// MARK: - Character Extensions

fileprivate extension Character {
    var isASCIIAlpha: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        return (scalar >= "A" && scalar <= "Z") || (scalar >= "a" && scalar <= "z")
    }

    var isASCIIAlphanumeric: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        return isASCIIAlpha || (scalar >= "0" && scalar <= "9")
    }

    var isASCIIDigit: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        return scalar >= "0" && scalar <= "9"
    }
}

// MARK: - URL Parsing

extension WHATWG_URL.Parser {
    /// Parses a URL from a string per WHATWG URL Standard Section 4.3
    ///
    /// Implements the Basic URL Parser state machine with support for:
    /// - Absolute URLs: `https://example.com/path`
    /// - Relative URLs: `/path`, `./file`, `../parent`
    /// - Special schemes: http, https, ws, wss, ftp, file
    /// - Non-special schemes: data, mailto, etc.
    ///
    /// ## State Machine
    ///
    /// The parser implements a state machine with the following states:
    /// - scheme start, scheme, no scheme
    /// - authority, host, port
    /// - path start, path
    /// - query, fragment
    ///
    /// ## Mathematical Properties
    ///
    /// - **Partiality**: Returns nil for invalid URLs
    /// - **Normalization**: Applies percent-encoding, path normalization, etc.
    /// - **Base URL Resolution**: Resolves relative URLs against base
    ///
    /// - Parameter input: The string to parse as a URL
    /// - Parameter base: Optional base URL for relative URL resolution
    /// - Returns: Parsed URL, or nil if the string is not a valid URL
    public static func parse(_ input: some StringProtocol, base: WHATWG_URL.URL? = nil) -> WHATWG_URL.URL? {
        // State machine variables
        var url = URLBuilder()
        var state = State.schemeStart
        var buffer = ""
        var atSignSeen = false

        // Prepare input: remove leading/trailing C0 controls and spaces
        let trimmed = String(input).trimmingCharacters(in: .whitespacesAndNewlines)
        let chars = Array(trimmed)
        var pointer = 0

        // State machine loop
        while pointer <= chars.count {
            let c = pointer < chars.count ? chars[pointer] : nil

            switch state {
            case .schemeStart:
                if let ch = c, ch.isASCIIAlpha {
                    buffer.append(ch.lowercased())
                    state = .scheme
                } else if base != nil {
                    state = .noScheme
                    pointer -= 1  // Reprocess this character
                } else {
                    return nil  // No scheme and no base
                }

            case .scheme:
                if let ch = c, (ch.isASCIIAlphanumeric || ch == "+" || ch == "-" || ch == ".") {
                    buffer.append(ch.lowercased())
                } else if c == ":" {
                    // Scheme complete
                    guard let scheme = WHATWG_URL.URL.Scheme(buffer) else {
                        return nil
                    }
                    url.scheme = scheme
                    buffer = ""

                    // Transition based on scheme
                    if WHATWG_URL.URL.Scheme.isSpecial(scheme) {
                        state = .specialAuthoritySlashes
                    } else if pointer + 1 < chars.count && chars[pointer + 1] == "/" {
                        state = .pathOrAuthority
                        pointer += 1
                    } else {
                        state = .opaquePath
                    }
                } else {
                    // Invalid scheme
                    return nil
                }

            case .noScheme:
                // Must have a base URL
                guard let base = base else {
                    return nil
                }

                // Copy scheme from base
                url.scheme = base.scheme

                if c == nil {
                    // Empty relative URL - copy everything from base
                    return base
                } else if c == "/" {
                    state = .pathStart
                } else if c == "?" {
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    state = .query
                } else if c == "#" {
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    url.query = base.query
                    state = .fragment
                } else {
                    // Relative path
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    state = .relativePath
                    pointer -= 1
                }

            case .specialAuthoritySlashes:
                if c == "/" && pointer + 1 < chars.count && chars[pointer + 1] == "/" {
                    state = .authority
                    pointer += 1
                } else {
                    // Missing //
                    return nil
                }

            case .pathOrAuthority:
                if c == "/" {
                    state = .authority
                } else {
                    state = .path
                    pointer -= 1
                }

            case .authority:
                if c == "@" {
                    // Parse username/password
                    if atSignSeen {
                        buffer = "%40" + buffer
                    }
                    atSignSeen = true

                    // Split on ":"
                    if let colonIndex = buffer.firstIndex(of: ":") {
                        url.username = WHATWG_URL.PercentEncoding.encode(
                            String(buffer[..<colonIndex]),
                            using: .userinfo
                        )
                        url.password = WHATWG_URL.PercentEncoding.encode(
                            String(buffer[buffer.index(after: colonIndex)...]),
                            using: .userinfo
                        )
                    } else {
                        url.username = WHATWG_URL.PercentEncoding.encode(buffer, using: .userinfo)
                    }
                    buffer = ""
                } else if c == nil || c == "/" || c == "?" || c == "#" {
                    // End of authority - parse host
                    pointer -= buffer.count + 1
                    state = .host
                } else {
                    buffer.append(c!)
                }

            case .host:
                // Collect host until delimiter
                while pointer < chars.count {
                    let ch = chars[pointer]
                    if ch == ":" || ch == "/" || ch == "?" || ch == "#" {
                        break
                    }
                    buffer.append(ch)
                    pointer += 1
                }

                // Parse host
                let isSpecial = WHATWG_URL.URL.Scheme.isSpecial(url.scheme!)
                guard let host = WHATWG_URL.URL.Host.parse(buffer, isSpecial: isSpecial) else {
                    return nil
                }
                url.host = host
                buffer = ""

                // Check for port
                if pointer < chars.count && chars[pointer] == ":" {
                    state = .port
                } else {
                    state = .pathStart
                    pointer -= 1
                }

            case .port:
                if let ch = c, ch.isASCIIDigit {
                    buffer.append(ch)
                } else {
                    // Parse port
                    if !buffer.isEmpty {
                        guard let port = UInt16(buffer) else {
                            return nil
                        }

                        // Only set if not default port for scheme
                        let defaultPort = WHATWG_URL.URL.Scheme.defaultPort(for: url.scheme!)
                        if port != defaultPort {
                            url.port = port
                        }
                        buffer = ""
                    }
                    state = .pathStart
                    pointer -= 1
                }

            case .pathStart:
                state = .path
                if c != "/" {
                    pointer -= 1
                }

            case .path:
                if c == nil || c == "/" || c == "?" || c == "#" {
                    // Normalize and add segment
                    if !buffer.isEmpty {
                        let decoded = WHATWG_URL.PercentEncoding.decode(buffer)

                        // Handle . and ..
                        if decoded == ".." {
                            url.popPathSegment()
                        } else if decoded != "." {
                            url.pushPathSegment(decoded)
                        }
                        buffer = ""
                    }

                    if c == "/" {
                        // Continue path
                    } else if c == "?" {
                        state = .query
                    } else if c == "#" {
                        state = .fragment
                    } else {
                        // End of URL
                        pointer -= 1
                        break
                    }
                } else {
                    buffer.append(c!)
                }

            case .relativePath:
                // Similar to path but inherits base path
                state = .path
                if c != "/" {
                    // Inherit base path except last segment
                    if case .list(var segments) = url.path {
                        if !segments.isEmpty {
                            segments.removeLast()
                        }
                        url.path = .list(segments)
                    }
                    pointer -= 1
                }

            case .opaquePath:
                // Non-special scheme path - no normalization
                while pointer < chars.count {
                    let ch = chars[pointer]
                    if ch == "?" || ch == "#" {
                        break
                    }
                    buffer.append(ch)
                    pointer += 1
                }

                url.path = .opaque(WHATWG_URL.PercentEncoding.encode(buffer, using: .component))
                buffer = ""

                if pointer < chars.count {
                    let ch = chars[pointer]
                    if ch == "?" {
                        state = .query
                    } else if ch == "#" {
                        state = .fragment
                    }
                } else {
                    pointer -= 1
                }

            case .query:
                while pointer < chars.count {
                    let ch = chars[pointer]
                    if ch == "#" {
                        pointer -= 1
                        break
                    }
                    buffer.append(ch)
                    pointer += 1
                }

                url.query = WHATWG_URL.PercentEncoding.encode(buffer, using: .query)
                buffer = ""

                if pointer < chars.count && chars[pointer] == "#" {
                    state = .fragment
                } else {
                    pointer -= 1
                }

            case .fragment:
                // Collect rest as fragment
                while pointer < chars.count {
                    buffer.append(chars[pointer])
                    pointer += 1
                }

                url.fragment = WHATWG_URL.PercentEncoding.encode(buffer, using: .fragment)
                buffer = ""
                pointer -= 1
            }

            pointer += 1
        }

        return url.build()
    }
}

// MARK: - Primitive Parsers (Stubs)

extension WHATWG_URL.URL.Scheme {
    /// Parses a scheme from a string
    ///
    /// Per WHATWG URL Standard, a valid scheme:
    /// - Starts with ASCII alpha
    /// - Followed by ASCII alphanumeric, +, -, or .
    /// - Case-insensitive (normalized to lowercase)
    ///
    /// ## Mathematical Properties
    ///
    /// - **Partiality**: Returns nil for invalid schemes
    /// - **Normalization**: Always returns lowercase
    /// - **Idempotence**: parse(parse(s)!.value) = parse(s)
    ///
    /// - Parameter string: The string to parse as a scheme
    /// - Returns: Parsed, normalized scheme, or nil if invalid
    public static func parse(_ string: some StringProtocol) -> Self? {
        // Delegate to existing failable initializer which already implements
        // the complete WHATWG scheme validation rules
        return Self(string)
    }
}

extension WHATWG_URL.URL.Host {
    /// Parses a host from a string per WHATWG URL Standard Section 4.5
    ///
    /// Per the WHATWG spec, host parsing follows this order:
    /// 1. IPv6 (if starts with `[`)
    /// 2. IPv4 (if looks like IPv4)
    /// 3. Domain (if special scheme)
    /// 4. Opaque (if non-special scheme)
    ///
    /// ## Mathematical Properties
    ///
    /// - **Partiality**: Returns nil for invalid hosts
    /// - **Normalization**: Domains are IDNA-encoded, IPv4/IPv6 canonical forms
    /// - **Composition**: Delegates to IPv4/IPv6/Domain parsers
    ///
    /// - Parameters:
    ///   - string: The string to parse as a host
    ///   - isSpecial: Whether this is for a special scheme (affects domain vs opaque)
    /// - Returns: Parsed host, or nil if invalid
    public static func parse(_ string: some StringProtocol, isSpecial: Bool = true) -> Self? {
        let input = String(string)

        // Empty string → empty host
        if input.isEmpty {
            return .empty
        }

        // IPv6: starts with [
        if input.hasPrefix("[") {
            guard input.hasSuffix("]") else { return nil }
            let ipv6String = String(input.dropFirst().dropLast())
            guard let addr = RFC_4291.IPv6.Address(whatwgString: ipv6String) else {
                return nil
            }
            return .ipv6(addr)
        }

        // Try IPv4 parsing (WHATWG supports many formats)
        if let ipv4 = RFC_791.IPv4.Address(whatwgString: input) {
            return .ipv4(ipv4)
        }

        // For special schemes: parse as domain
        if isSpecial {
            // Percent-decode first
            let decoded = WHATWG_URL.PercentEncoding.decode(input)

            // Parse as domain (uses IDNA)
            guard let domain = try? Domain_Standard.Domain(decoded) else {
                return nil
            }

            return .domain(domain)
        }

        // For non-special schemes: opaque host
        // Percent-encode if needed
        let encoded = WHATWG_URL.PercentEncoding.encode(input, using: .component)
        return .opaque(encoded)
    }
}

extension WHATWG_URL.URL.Path {
    /// Parses a path from a string per WHATWG URL Standard
    ///
    /// Handles:
    /// - Segment splitting on "/"
    /// - Percent-decoding of segments
    /// - Normalization: "." and ".." processing
    /// - Opaque vs list path distinction
    ///
    /// ## Normalization Rules
    ///
    /// - "." segments are removed
    /// - ".." segments pop the last segment (if not at root)
    /// - Leading "/" preserved for list paths
    /// - Empty segments normalized out (except for single empty at root)
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Always returns a valid path
    /// - **Normalization**: `parse(serialize(parse(s))) = parse(s)`
    /// - **Canonical form**: Minimal representation
    ///
    /// - Parameters:
    ///   - string: The string to parse as a path
    ///   - isOpaque: Whether this is an opaque path (non-special schemes)
    /// - Returns: Parsed, normalized path
    public static func parse(_ string: some StringProtocol, isOpaque: Bool = false) -> Self {
        let input = String(string)

        // Opaque paths: no normalization, just percent-decode
        if isOpaque {
            let decoded = WHATWG_URL.PercentEncoding.decode(input)
            return .opaque(decoded)
        }

        // List paths: split on /, normalize ., ..
        var segments: [String] = []

        for segment in input.split(separator: "/", omittingEmptySubsequences: false) {
            let decoded = WHATWG_URL.PercentEncoding.decode(String(segment))

            // Normalize . and ..
            if decoded == "." {
                // Skip . segments
                continue
            } else if decoded == ".." {
                // Pop last segment (if not at root)
                if !segments.isEmpty {
                    segments.removeLast()
                }
            } else if !decoded.isEmpty || segments.isEmpty {
                // Keep non-empty segments, or first empty (for leading /)
                segments.append(decoded)
            }
        }

        return .list(segments)
    }
}
