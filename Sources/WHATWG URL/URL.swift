#if canImport(FoundationEssentials)
public import FoundationEssentials
#elseif canImport(Foundation)
public import Foundation
#endif

public import WHATWG_Form_URL_Encoded
public import RFC_3987

/// WHATWG URL Standard implementation
///
/// This module implements the WHATWG URL Standard's URL parsing, serialization,
/// and manipulation algorithms.
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
/// print(url.scheme)    // "https"
/// print(url.host)      // "example.com"
/// print(url.port)      // 8080
/// print(url.pathname)  // "/path"
/// print(url.search)    // "?query=value"
/// print(url.hash)      // "#fragment"
///
/// // Serialize URL
/// let urlString = url.href  // "https://example.com:8080/path?query=value#fragment"
/// ```
public struct WHATWG_URL {
    // TODO: Implement URL structure per WHATWG URL Living Standard
    // - URL parser
    // - URL serializer
    // - URL components (scheme, username, password, host, port, path, query, fragment)
    // - SearchParams (URLSearchParams)
}
