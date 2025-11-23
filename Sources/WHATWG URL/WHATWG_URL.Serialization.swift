//
//  WHATWG_URL.Serialization.swift
//  swift-whatwg-url
//
//  Authoritative implementation of URL Serialization per WHATWG URL Standard Section 4.5

extension WHATWG_URL {
    /// URL Serialization (Section 4.5)
    ///
    /// Authoritative implementations for serializing URLs to ASCII strings.
    ///
    /// Per WHATWG URL Standard Section 4.5, URL serialization produces an ASCII string
    /// where parsing the result yields an equivalent URL.
    ///
    /// ## Components Serialized
    ///
    /// 1. Scheme + ":"
    /// 2. Authority (if present): "//" + credentials + host + port
    /// 3. Path
    /// 4. Query (if present): "?" + query
    /// 5. Fragment (if present): "#" + fragment
    public enum Serialization {}
}

// MARK: - URL Serialization

extension WHATWG_URL.Serialization {
    /// Serializes a URL to its string representation (href)
    ///
    /// This is the authoritative implementation per WHATWG URL Standard Section 4.5.
    ///
    /// - Parameter url: The URL to serialize
    /// - Returns: ASCII string representation
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: This function is total - always produces a valid ASCII String
    /// - **Injectivity**: Different URLs produce different strings (up to normalization)
    /// - **Idempotence**: `serialize(parse(serialize(url))) = serialize(url)` (after normalization)
    /// - **Specification Compliance**: Output is parseable - `parse(serialize(url))` yields equivalent URL
    ///
    /// ## Category Theory
    ///
    /// This function represents a morphism in the category of URLs:
    /// - **Domain**: `WHATWG_URL.URL` (all valid URLs)
    /// - **Codomain**: `String` (ASCII strings)
    /// - **Nature**: Total, deterministic serialization morphism
    /// - **Inverse**: Partial morphism via `WHATWG_URL.parse` (not all strings are valid URLs)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let serialized = WHATWG_URL.Serialization.serialize(url)
    /// // "https://user:pass@example.com:8080/path?query=value#fragment"
    /// ```
    @inlinable
    public static func serialize(_ url: WHATWG_URL.URL) -> String {
        var output = ""

        // Scheme
        output += url.scheme.value
        output += ":"

        // Authority (host with optional credentials and port)
        if let host = url.host {
            output += "//"

            // Credentials
            if url.includesCredentials {
                if !url.username.isEmpty {
                    output += url.username
                }
                if !url.password.isEmpty {
                    output += ":"
                    output += url.password
                }
                output += "@"
            }

            // Host
            output += WHATWG_URL.URL.Host.serialize(host)

            // Port (only if not the default for this scheme)
            if let port = url.port {
                if WHATWG_URL.URL.Scheme.defaultPort(for: url.scheme) != port {
                    output += ":"
                    output += String(port)
                }
            }
        } else if url.hasOpaquePath {
            // For opaque paths without host
        } else if url.scheme.value == "file" {
            // file: URLs always have //
            output += "//"
        }

        // Path
        output += WHATWG_URL.URL.Path.serialize(url.path)

        // Query
        if let query = url.query {
            output += "?"
            output += query
        }

        // Fragment
        if let fragment = url.fragment {
            output += "#"
            output += fragment
        }

        return output
    }

    /// Serializes just the origin portion of a URL
    ///
    /// Per WHATWG URL Standard Section 4.7, the origin consists of:
    /// - For special schemes: scheme + "://" + host + port (if non-default)
    /// - For non-special schemes: "null" (opaque origin)
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Total function - always returns a valid String
    /// - **Determinism**: Same URL always produces same origin string
    /// - **Non-injectivity**: Different URLs may have same origin (path/query/fragment differences)
    /// - **Equivalence Classes**: Origins partition URLs into same-origin equivalence classes
    ///
    /// ## Security Properties
    ///
    /// - Origins are the basis for same-origin policy in web security
    /// - Two URLs with same origin can access each other's resources
    /// - Opaque origins ("null") never match any origin, including themselves
    ///
    /// - Parameter url: The URL to extract origin from
    /// - Returns: Origin string
    @inlinable
    public static func serializeOrigin(_ url: WHATWG_URL.URL) -> String {
        guard url.isSpecial else {
            return "null"
        }

        var output = url.scheme.value + "://"

        if let host = url.host {
            output += WHATWG_URL.URL.Host.serialize(host)
        }

        if let port = url.port, WHATWG_URL.URL.Scheme.defaultPort(for: url.scheme) != port {
            output += ":" + String(port)
        }

        return output
    }
}
