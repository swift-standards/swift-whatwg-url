//
//  String+WHATWG_URL.swift
//  swift-whatwg-url
//
//  WHATWG URL Standard extensions for String
//  Provides URL serialization per WHATWG URL Standard Section 4.5
//
//  This file contains ONLY delegation to authoritative implementations.
//  All serialization logic is in WHATWG_URL.Serialization.

// MARK: - Namespace Wrapper



// MARK: - StringProtocol Extension for Namespace Access

extension StringProtocol {
    /// Access to WHATWG URL operations
    public static var whatwgURL: WHATWG_URL.StringProtocol<Self>.Type {
        WHATWG_URL.StringProtocol<Self>.self
    }

    /// Access to WHATWG URL operations for this string
    public var whatwgURL: WHATWG_URL.StringProtocol<Self> {
        WHATWG_URL.StringProtocol(self)
    }
}

// MARK: - Serialization: WHATWG_URL → String

extension String {
    /// Creates a string by serializing a WHATWG URL
    ///
    /// Defers to authoritative implementation in `WHATWG_URL.Serialization`.
    ///
    /// Per WHATWG URL Standard Section 4.5, URL serialization produces an ASCII string
    /// where parsing the result yields an equivalent URL.
    ///
    /// - Parameter whatwgURL: The URL to serialize
    /// - Returns: Serialized URL string (href)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let urlString = String(whatwgURL: url)
    /// // "https://example.com/path?query=value#fragment"
    /// ```
    @inlinable
    public init(whatwgURL url: WHATWG_URL.URL) {
        self = WHATWG_URL.Serialization.serialize(url)
    }

    /// Creates a string from the URL's origin
    ///
    /// Defers to authoritative implementation in `WHATWG_URL.Serialization`.
    ///
    /// - Parameter origin: The URL to extract origin from
    /// - Returns: Origin string or "null" for opaque origins
    @inlinable
    public init(whatwgOrigin url: WHATWG_URL.URL) {
        self = WHATWG_URL.Serialization.serializeOrigin(url)
    }
}

// MARK: - URL Serialization

extension WHATWG_URL.StringProtocol {
    /// Serializes a URL to its string representation
    ///
    /// Pure delegation to authoritative implementation `WHATWG_URL.Serialization.serialize`.
    ///
    /// ## Delegation Pattern
    ///
    /// This function composes primitive serialization operations:
    /// - Scheme serialization (via `.value`)
    /// - Host serialization (via `Host.serialize`)
    /// - Path serialization (via `Path.serialize`)
    /// - Query/fragment as-is (already strings)
    ///
    /// - Parameter url: The URL to serialize
    /// - Returns: Serialized URL string
    @inlinable
    public static func serialize(_ url: WHATWG_URL.URL) -> S {
        S(WHATWG_URL.Serialization.serialize(url))!
    }

    /// Serializes just the origin portion of a URL
    ///
    /// Pure delegation to authoritative implementation `WHATWG_URL.Serialization.serializeOrigin`.
    ///
    /// - Parameter url: The URL to extract origin from
    /// - Returns: Origin string
    @inlinable
    public static func serializeOrigin(_ url: WHATWG_URL.URL) -> S {
        S(WHATWG_URL.Serialization.serializeOrigin(url))!
    }
}

extension String {
    /// Creates a string representation of a WHATWG URL Host
    ///
    /// Delegates to authoritative implementation `Host.serialize()`.
    ///
    /// ## Delegation Pattern
    ///
    /// This is pure delegation to the static `Host.serialize()` function.
    /// The authoritative implementation handles:
    /// - IPv4: RFC 791 dotted-decimal notation
    /// - IPv6: RFC 5952 canonical text representation (with `[...]` brackets per WHATWG URL)
    /// - Domain: IDNA-encoded domain name
    /// - Opaque: Percent-encoded host string
    /// - Empty: Empty string
    ///
    /// ## Category Theory
    ///
    /// This is a coproduct elimination - the Host sum type is eliminated by
    /// the unique authoritative morphism `Host.serialize()`.
    ///
    /// - Parameter host: The WHATWG URL host to serialize
    @inlinable
    public init(_ host: WHATWG_URL.URL.Host) {
        self = WHATWG_URL.URL.Host.serialize(host)
    }

    /// Creates a string representation of a WHATWG URL Path
    ///
    /// Delegates to authoritative implementation `Path.serialize()`.
    ///
    /// ## Delegation Pattern
    ///
    /// This is pure delegation to the static `Path.serialize()` function.
    /// The authoritative implementation handles:
    /// - Opaque path: Serialized as-is (percent-encoded string)
    /// - List path: Serialized as "/" + segments joined by "/"
    /// - Empty list: Serialized as "" (no leading slash)
    ///
    /// - Parameter path: The WHATWG URL path to serialize
    @inlinable
    public init(_ path: WHATWG_URL.URL.Path) {
        self = WHATWG_URL.URL.Path.serialize(path)
    }

    /// Creates a string representation of WHATWG URL Search Parameters
    ///
    /// Delegates to the search parameters' string representation.
    ///
    /// The `toString()` method delegates to the authoritative implementation
    /// in `WHATWG_Form_URL_Encoded.serialize`.
    ///
    /// - Parameter searchParams: The search parameters to serialize
    ///
    /// ## Example
    ///
    /// ```swift
    /// var params = WHATWG_URL.URL.Search.Params()
    /// params.append("name", "John Doe")
    /// params.append("email", "john@example.com")
    /// let query = String(searchParams: params)
    /// // "name=John+Doe&email=john%40example.com"
    /// ```
    @inlinable
    public init(_ searchParams: WHATWG_URL.URL.Search.Params) {
        self = searchParams.toString()
    }
}
