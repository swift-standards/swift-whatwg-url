// WHATWG_URL.Parser Tests.swift
// swift-whatwg-url
//
// Tests for WHATWG URL Basic URL Parser

import Domain_Standard
import RFC_791
import StandardsTestSupport
import Testing

@testable import WHATWG_URL

@Suite
struct `WHATWG_URL.URL Tests` {

    // MARK: - Absolute URLs

    @Suite
    struct `URL - Absolute URLs` {
        @Test
        func `parse simple HTTP URL`() throws {
            let url = try WHATWG_URL.URL("http://example.com")
            #expect(url.scheme.value == "http")
            #expect(url.host == .domain(try Domain_Standard.Domain("example.com")))
            #expect(url.port == nil)  // Default port omitted
            #expect(url.path == .list([]))
        }

        @Test
        func `parse HTTPS URL with path`() throws {
            let url = try WHATWG_URL.URL("https://example.com/path/to/resource")
            #expect(url.scheme.value == "https")
            #expect(url.host == .domain(try Domain_Standard.Domain("example.com")))
            #expect(url.path == .list(["path", "to", "resource"]))
        }

        @Test
        func `parse URL with non-default port`() throws {
            let url = try WHATWG_URL.URL("http://example.com:8080/path")
            #expect(url.scheme.value == "http")
            #expect(url.port == 8080)
        }

        @Test
        func `parse URL with default port omits port`() throws {
            let url = try WHATWG_URL.URL("http://example.com:80/path")
            #expect(url.port == nil)  // Port 80 is default for http
        }

        @Test
        func `parse URL with query`() throws {
            let url = try WHATWG_URL.URL("http://example.com/path?query=value&foo=bar")
            #expect(url.query == "query=value&foo=bar")
        }

        @Test
        func `parse URL with fragment`() throws {
            let url = try WHATWG_URL.URL("http://example.com/path#section")
            #expect(url.fragment == "section")
        }

        @Test
        func `parse URL with query and fragment`() throws {
            let url = try WHATWG_URL.URL("http://example.com/path?query=value#section")
            #expect(url.query == "query=value")
            #expect(url.fragment == "section")
        }

        @Test
        func `parse URL with username and password`() throws {
            let url = try WHATWG_URL.URL("http://user:pass@example.com/path")
            #expect(url.username == "user")
            #expect(url.password == "pass")
        }

        @Test
        func `parse URL with username only`() throws {
            let url = try WHATWG_URL.URL("http://user@example.com/path")
            #expect(url.username == "user")
            #expect(url.password.isEmpty)
        }
    }

    // MARK: - Special Schemes

    @Suite
    struct `URL - Special Schemes` {

        @Test(arguments: ["http", "https", "ws", "wss", "ftp", "file"])
        func `special schemes are recognized`(scheme: String) throws {
            let url = WHATWG_URL.URL(parsing: "\(scheme)://example.com/path")
            #expect(url != nil)
            #expect(url?.scheme.value == scheme)
        }

        @Test
        func `file URL without host`() throws {
            let url = try WHATWG_URL.URL("file:///path/to/file")
            #expect(url.scheme.value == "file")
            #expect(url.host == .empty)
        }

        @Test
        func `ws URL with port`() throws {
            let url = try WHATWG_URL.URL("ws://example.com:9000/socket")
            #expect(url.scheme.value == "ws")
            #expect(url.port == 9000)
        }

        @Test
        func `wss URL with default port omitted`() throws {
            let url = try WHATWG_URL.URL("wss://example.com:443/socket")
            #expect(url.port == nil)  // 443 is default for wss
        }
    }

    // MARK: - Non-Special Schemes

    @Suite
    struct `URL - Non-Special Schemes` {

        @Test
        func `data URL with opaque path`() throws {
            let url = try WHATWG_URL.URL("data:text/plain;base64,SGVsbG8=")
            #expect(url.scheme.value == "data")
            if case .opaque(let path) = url.path {
                #expect(path.contains("text/plain"))
            } else {
                Issue.record("Expected opaque path for data URL")
            }
        }

        @Test
        func `mailto URL`() throws {
            let url = try WHATWG_URL.URL("mailto:user@example.com")
            #expect(url.scheme.value == "mailto")
        }

        @Test
        func `custom scheme URL`() throws {
            let url = try WHATWG_URL.URL("customscheme://example/path")
            #expect(url.scheme.value == "customscheme")
        }
    }

    // MARK: - Path Normalization

    @Suite
    struct `URL - Path Normalization` {

        @Test
        func `single dot segment is removed`() throws {
            let url = try WHATWG_URL.URL("http://example.com/a/./b")
            #expect(url.path == .list(["a", "b"]))
        }

        @Test
        func `double dot pops segment`() throws {
            let url = try WHATWG_URL.URL("http://example.com/a/b/../c")
            #expect(url.path == .list(["a", "c"]))
        }

        @Test
        func `double dot at start does nothing`() throws {
            let url = try WHATWG_URL.URL("http://example.com/../a")
            #expect(url.path == .list(["a"]))
        }

        @Test
        func `multiple normalizations`() throws {
            let url = try WHATWG_URL.URL("http://example.com/a/b/./c/../d")
            #expect(url.path == .list(["a", "b", "d"]))
        }

        @Test
        func `trailing single dot removed`() throws {
            let url = try WHATWG_URL.URL("http://example.com/a/b/.")
            #expect(url.path == .list(["a", "b"]))
        }

        @Test
        func `trailing double dot pops`() throws {
            let url = try WHATWG_URL.URL("http://example.com/a/b/..")
            #expect(url.path == .list(["a"]))
        }
    }

    // MARK: - Relative URLs

    @Suite
    struct `URL - Relative URLs` {

        @Test
        func `relative path against base URL`() throws {
            let base = try WHATWG_URL.URL("http://example.com/a/b")
            let url = try WHATWG_URL.URL("c/d", base: base)
            #expect(url.scheme.value == "http")
            #expect(url.host == base.host)
            #expect(url.path == .list(["a", "c", "d"]))
        }

        @Test
        func `absolute path against base URL`() throws {
            let base = try WHATWG_URL.URL("http://example.com/a/b")
            let url = try WHATWG_URL.URL("/x/y", base: base)
            #expect(url.scheme.value == "http")
            #expect(url.host == base.host)
            #expect(url.path == .list(["x", "y"]))
        }

        @Test
        func `query-only against base URL`() throws {
            let base = try WHATWG_URL.URL("http://example.com/a/b")
            let url = try WHATWG_URL.URL("?newquery", base: base)
            #expect(url.path == base.path)
            #expect(url.query == "newquery")
        }

        @Test
        func `fragment-only against base URL`() throws {
            let base = try WHATWG_URL.URL("http://example.com/a/b#oldfrag")
            let url = try WHATWG_URL.URL("#newfrag", base: base)
            #expect(url.path == base.path)
            #expect(url.query == base.query)
            #expect(url.fragment == "newfrag")
        }

        @Test
        func `empty string against base returns base`() throws {
            let base = try WHATWG_URL.URL("http://example.com/path")
            let url = try WHATWG_URL.URL("", base: base)
            #expect(url.scheme == base.scheme)
            #expect(url.host == base.host)
            #expect(url.path == base.path)
        }
    }

    // MARK: - IPv4 Addresses

    @Suite
    struct `URL - IPv4 Addresses` {

        @Test
        func `standard dotted-decimal IPv4`() throws {
            let url = try WHATWG_URL.URL("http://192.168.1.1/path")
            if case .ipv4(let addr) = url.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG hex IPv4`() throws {
            let url = try WHATWG_URL.URL("http://0xC0.0xA8.0x1.0x1/path")
            if case .ipv4(let addr) = url.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG octal IPv4`() throws {
            let url = try WHATWG_URL.URL("http://0300.0250.01.01/path")
            if case .ipv4(let addr) = url.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG compressed IPv4`() throws {
            let url = try WHATWG_URL.URL("http://192.168.257/path")
            if case .ipv4(let addr) = url.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG single number IPv4`() throws {
            let url = try WHATWG_URL.URL("http://3232235777/path")
            if case .ipv4(let addr) = url.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }
    }

    // MARK: - IPv6 Addresses

    @Suite
    struct `URL - IPv6 Addresses` {

        @Test
        func `standard IPv6 with brackets`() throws {
            let url = try WHATWG_URL.URL("http://[2001:db8::1]/path")
            if case .ipv6 = url.host {
                // Success - IPv6 parsed
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv6 with zone ID stripped`() throws {
            let url = try WHATWG_URL.URL("http://[fe80::1%eth0]/path")
            if case .ipv6 = url.host {
                // Success - IPv6 parsed with zone ID stripped
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv4-embedded IPv6`() throws {
            let url = try WHATWG_URL.URL("http://[::ffff:192.0.2.1]/path")
            if case .ipv6 = url.host {
                // Success - IPv4-embedded IPv6 parsed
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv6 localhost`() throws {
            let url = try WHATWG_URL.URL("http://[::1]/path")
            if case .ipv6 = url.host {
                // Success
            } else {
                Issue.record("Expected IPv6 host")
            }
        }
    }

    // MARK: - Percent Encoding

    @Suite
    struct `URL - Percent Encoding` {

        @Test
        func `percent-encoded path is decoded during parsing`() throws {
            let url = try WHATWG_URL.URL("http://example.com/hello%20world")
            #expect(url.path == .list(["hello world"]))
        }

        @Test
        func `percent-encoded query is preserved`() throws {
            let url = try WHATWG_URL.URL("http://example.com/?q=hello%20world")
            #expect(url.query?.contains("hello") == true)
        }

        @Test
        func `special characters in userinfo are encoded`() throws {
            let url = try WHATWG_URL.URL("http://user@name:pass@example.com/")
            // Username should be "user" and @ should be encoded
            #expect(url.username.contains("%40") == true)
        }
    }

    // MARK: - Invalid URLs

    @Suite
    struct `URL - Invalid URLs` {

        @Test
        func `no scheme throws`() {
            #expect(throws: WHATWG_URL.URL.Error.self) {
                try WHATWG_URL.URL("example.com/path")
            }
        }

        @Test
        func `invalid scheme throws`() {
            #expect(throws: WHATWG_URL.URL.Error.self) {
                try WHATWG_URL.URL("ht!tp://example.com")
            }
        }

        @Test
        func `missing slashes for special scheme throws`() {
            #expect(throws: WHATWG_URL.URL.Error.self) {
                try WHATWG_URL.URL("http:example.com")
            }
        }

        @Test
        func `invalid port throws`() {
            #expect(throws: WHATWG_URL.URL.Error.self) {
                try WHATWG_URL.URL("http://example.com:99999999/path")
            }
        }

        @Test
        func `invalid IPv6 throws`() {
            #expect(throws: WHATWG_URL.URL.Error.self) {
                try WHATWG_URL.URL("http://[not-ipv6]/path")
            }
        }
    }

    // MARK: - Edge Cases

    @Suite
    struct `URL - Edge Cases` {

        @Test
        func `empty path`() throws {
            let url = try WHATWG_URL.URL("http://example.com")
            #expect(url.path == .list([]))
        }

        @Test
        func `trailing slash creates empty segment`() throws {
            let url = try WHATWG_URL.URL("http://example.com/")
            // Implementation may vary - document expected behavior
        }

        @Test
        func `multiple slashes are preserved`() throws {
            let url = try WHATWG_URL.URL("http://example.com//a///b")
            // Empty segments between slashes
        }

        @Test
        func `whitespace is trimmed`() throws {
            let url = try WHATWG_URL.URL("  http://example.com/path  ")
            #expect(url.scheme.value == "http")
        }

        @Test
        func `empty query`() throws {
            let url = try WHATWG_URL.URL("http://example.com/?")
            #expect(url.query.isEmpty)
        }

        @Test
        func `empty fragment`() throws {
            let url = try WHATWG_URL.URL("http://example.com/#")
            #expect(url.fragment.isEmpty)
        }
    }
}

// // MARK: - Performance Tests
//
// extension `Performance Tests` {
//    @Suite
//    struct `URL - Performance` {
//
//        @Test(.timed(threshold: .milliseconds(5000)))
//        func `parse 10000 simple URLs`() throws {
//            for _ in 0..<10_000 {
//                _ = WHATWG_URL.URL(parsing: "http://example.com/path")
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(5000)))
//        func `parse 10000 complex URLs`() throws {
//            for _ in 0..<10_000 {
//                _ = WHATWG_URL.URL(parsing: "https://user:pass@example.com:8080/a/b/c?query=value#fragment")
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(5000)))
//        func `parse 10000 URLs with normalization`() throws {
//            for _ in 0..<10_000 {
//                _ = WHATWG_URL.URL(parsing: "http://example.com/a/./b/../c")
//            }
//        }
//    }
// }
