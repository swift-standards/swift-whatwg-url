import RFC_3987
import WHATWG_Form_URL_Encoded

/// A URL as defined by the WHATWG URL Living Standard
///
/// A URL is a universal identifier. Unlike URIs (RFC 3986), URLs are living standard
/// compliant and use modern parsing algorithms that match browser behavior.
///
/// ## Reference
///
/// WHATWG URL Living Standard:
/// https://url.spec.whatwg.org/
///
/// ## Architecture
///
/// This implementation builds on:
/// - `WHATWG_Form_URL_Encoded`: For application/x-www-form-urlencoded parsing (Section 5)
/// - `RFC_3987`: For IRI (Internationalized Resource Identifier) support
///
/// ## Example
///
/// ```swift
/// // Parse a URL
/// let url = try WHATWG_URL.parse("https://example.com:8080/path?query=value#fragment")
///
/// // Access URL components
/// print(url.scheme)      // "https"
/// print(url.host)        // Optional(.domain("example.com"))
/// print(url.port)        // Optional(8080)
/// print(url.path)        // .list(["path"])
/// print(url.query)       // Optional("query=value")
/// print(url.fragment)    // Optional("fragment")
///
/// // Serialize URL
/// let urlString = url.href  // "https://example.com:8080/path?query=value#fragment"
/// ```
extension WHATWG_URL {
    public struct URL: Hashable, Sendable {
        /// The URL's scheme (e.g., "https", "http", "file")
        public var scheme: Scheme

        /// The URL's username (for authentication)
        public var username: String

        /// The URL's password (for authentication)
        public var password: String

        /// The URL's host (domain, IPv4, IPv6, opaque, or empty)
        public var host: Host?

        /// The URL's port (null or 16-bit unsigned integer)
        public var port: UInt16?

        /// The URL's path (opaque string or list of segments)
        public var path: Path

        /// The URL's query string (without leading "?")
        public var query: String?

        /// The URL's fragment (without leading "#")
        public var fragment: String?

        /// Creates a URL with the specified components
        ///
        /// This is the **direct constructor** for creating URLs from validated components.
        /// Use this when you already have parsed/validated URL components.
        ///
        /// For parsing URLs from strings, use `WHATWG_URL.Parser.parse(_:)` (when implemented).
        ///
        /// - Parameters:
        ///   - scheme: The URL's scheme (required)
        ///   - username: The URL's username for authentication (default: "")
        ///   - password: The URL's password for authentication (default: "")
        ///   - host: The URL's host (default: nil)
        ///   - port: The URL's port (default: nil)
        ///   - path: The URL's path (default: empty list)
        ///   - query: The URL's query string without "?" (default: nil)
        ///   - fragment: The URL's fragment without "#" (default: nil)
        public init(
            scheme: Scheme,
            username: String = "",
            password: String = "",
            host: Host? = nil,
            port: UInt16? = nil,
            path: Path = .emptyList,
            query: String? = nil,
            fragment: String? = nil
        ) {
            self.scheme = scheme
            self.username = username
            self.password = password
            self.host = host
            self.port = port
            self.path = path
            self.query = query
            self.fragment = fragment
        }
    }
}

// MARK: - Computed Properties

extension WHATWG_URL.URL {
    /// Whether this URL has a special scheme
    public var isSpecial: Bool {
        Scheme.isSpecial(scheme)
    }

    /// Whether this URL has an opaque path
    public var hasOpaquePath: Bool {
        if case .opaque = path {
            return true
        }
        return false
    }

    /// Whether this URL includes credentials (username or password)
    public var includesCredentials: Bool {
        return !username.isEmpty || !password.isEmpty
    }

    /// Whether this URL can have a username/password/port
    public var cannotHaveUsernamePasswordPort: Bool {
        // Cannot have credentials if host is null/empty or scheme is "file"
        if host == nil || host == .empty {
            return true
        }
        return scheme.value == "file"
    }

    /// Returns Search.Params for this URL's query string
    ///
    /// ## Important: Copy-on-Access Semantics
    ///
    /// This computed property creates a **new** `Search.Params` instance on every access.
    /// Mutations to the returned value do **not** persist back to the URL.
    ///
    /// ❌ **This does not work:**
    /// ```swift
    /// url.searchParams.append("key", "value")  // Creates Params, modifies, discards
    /// // The modification is lost!
    /// ```
    ///
    /// ✅ **Instead, do this:**
    /// ```swift
    /// var params = url.searchParams
    /// params.append("key", "value")
    /// url.searchParams = params  // Explicitly assign back
    /// ```
    ///
    /// ## Mathematical Properties
    ///
    /// - **Get Operation**: Total function `URL → Search.Params`
    /// - **Set Operation**: Total function `Search.Params → URL`
    /// - **Round-trip**: `url.searchParams = params; assert(url.searchParams == params)` (holds)
    /// - **Idempotence**: `url.searchParams = url.searchParams` (no-op)
    ///
    /// ## Rationale
    ///
    /// This design follows WHATWG URL Standard Section 4.5 where query strings are
    /// serialized directly. The `Search.Params` type is a convenience view over the
    /// underlying percent-encoded query string, not a stored representation.
    public var searchParams: Search.Params {
        get {
            if let query = query {
                return Search.Params(query)
            }
            return Search.Params()
        }
        set {
            let serialized = newValue.toString()
            query = serialized.isEmpty ? nil : serialized
        }
    }
}

extension WHATWG_URL.URL {
    /// Returns the hypertext reference (href) - the normalized, serialized URL
    ///
    /// Pure delegation to authoritative implementation via `Href(url)`.
    ///
    /// ## Purpose
    ///
    /// This property provides the canonical, type-safe representation of the serialized URL.
    /// Per WHATWG URL Standard Section 4.5, the serialization produces an ASCII string
    /// where parsing the result yields an equivalent URL.
    ///
    /// ## Type Safety
    ///
    /// Returns `Href` (not `String`) to guarantee the result is a valid, normalized URL.
    /// This prevents mixing arbitrary strings with URL references:
    ///
    /// ```swift
    /// let href: Href = url.href        // Type-safe ✓
    /// let string: String = String(href)  // Explicit conversion when needed
    /// ```
    ///
    /// ## Usage Pattern
    ///
    /// For structured access to URL components, use the type-safe properties:
    /// - `url.scheme` → `Scheme` (type-safe)
    /// - `url.host` → `Host?` (type-safe)
    /// - `url.path` → `Path` (type-safe)
    /// - `url.query` → `String?`
    /// - `url.fragment` → `String?`
    ///
    /// Use `href` when you need the complete serialized URL as a validated, normalized reference.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Always produces a valid Href
    /// - **Determinism**: Same URL always produces same Href
    /// - **Idempotence**: `parse(url.href.value).href == url.href` (round-trip property)
    /// - **Normalization**: Result is the canonical representative of the URL's equivalence class
    ///
    /// - Returns: Type-safe Href (e.g., `Href("https://example.com:8080/path?query#fragment")`)
    public var href: Href {
        Href(self)
    }

    /// Returns the origin of the URL
    ///
    /// Pure delegation to authoritative implementation `WHATWG_URL.Serialization.serializeOrigin`.
    ///
    /// ## Purpose
    ///
    /// The origin is used for security checks in web contexts (same-origin policy).
    /// Per WHATWG URL Standard Section 4.7:
    /// - For special schemes: scheme + "://" + host + port (if non-default)
    /// - For non-special schemes: "null" (opaque origin)
    ///
    /// ## Security Properties
    ///
    /// - Origins partition URLs into equivalence classes
    /// - Two URLs with same origin can access each other's resources
    /// - Opaque origins ("null") never match any origin, including themselves
    ///
    /// ## Mathematical Properties
    ///
    /// - **Totality**: Always produces a valid String
    /// - **Non-injectivity**: Different URLs may have same origin
    /// - **Equivalence relation**: Defines same-origin equivalence classes
    ///
    /// - Returns: Origin string (e.g., "https://example.com:8080") or "null"
    public var origin: String {
        // Non-special schemes have opaque origin
        guard isSpecial else {
            return "null"
        }

        var output = scheme.value + "://"

        if let host = host {
            output += String(ascii: host)
        }

        if let port = port, Scheme.defaultPort(for: scheme) != port {
            output += ":" + String(port)
        }

        return output
    }
}
