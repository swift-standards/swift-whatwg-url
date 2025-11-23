import WHATWG_Form_URL_Encoded
import RFC_3987

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

        /// Parses a URL from a string
        ///
        /// Convenience initializer that delegates to `WHATWG_URL.Parser.parse`.
        ///
        /// ## Implementation Status
        ///
        /// ⚠️ **TODO**: This currently uses a stub parser that always returns nil.
        ///
        /// The full implementation requires the WHATWG URL Basic URL Parser (Section 4.3).
        ///
        /// - Parameter string: The string to parse as a URL
        /// - Parameter base: Optional base URL for relative URL resolution
        /// - Returns: Parsed URL, or nil if the string is not a valid URL
        public init?(_ string: some Swift.StringProtocol, base: URL? = nil) {
            guard let url = WHATWG_URL.Parser.parse(string, base: base) else {
                return nil
            }
            self = url
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
