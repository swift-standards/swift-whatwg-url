#if canImport(FoundationEssentials)
public import FoundationEssentials
#elseif canImport(Foundation)
public import Foundation
#endif

public import WHATWG_Form_URL_Encoded
public import RFC_3987

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
public struct WHATWG_URL: Hashable, Sendable {
    /// The URL's scheme (e.g., "https", "http", "file")
    public var scheme: String

    /// The URL's username (for authentication)
    public var username: String

    /// The URL's password (for authentication)
    public var password: String

    /// The URL's host (domain, IPv4, IPv6, opaque, or empty)
    public var host: URLHost?

    /// The URL's port (null or 16-bit unsigned integer)
    public var port: UInt16?

    /// The URL's path (opaque string or list of segments)
    public var path: URLPath

    /// The URL's query string (without leading "?")
    public var query: String?

    /// The URL's fragment (without leading "#")
    public var fragment: String?

    /// Creates a URL with the specified components
    public init(
        scheme: String,
        username: String = "",
        password: String = "",
        host: URLHost? = nil,
        port: UInt16? = nil,
        path: URLPath = .emptyList,
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

extension WHATWG_URL {
    /// Whether this URL has a special scheme
    public var isSpecial: Bool {
        URLScheme.isSpecial(scheme)
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
        return scheme == "file"
    }

    /// Returns URLSearchParams for this URL's query string
    public var searchParams: URLSearchParams {
        get {
            if let query = query {
                return URLSearchParams(query)
            }
            return URLSearchParams()
        }
        set {
            let serialized = newValue.toString()
            query = serialized.isEmpty ? nil : serialized
        }
    }
}
