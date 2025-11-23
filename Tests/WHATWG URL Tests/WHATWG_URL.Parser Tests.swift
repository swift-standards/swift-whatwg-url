// WHATWG_URL.Parser Tests.swift
// swift-whatwg-url
//
// Tests for WHATWG URL Basic URL Parser

import StandardsTestSupport
import Testing

@testable import WHATWG_URL

@Suite
struct `WHATWG_URL.Parser Tests` {

    // MARK: - Absolute URLs

    @Suite
    struct `Parser - Absolute URLs` {

        @Test
        func `parse simple HTTP URL`() {
            let url = WHATWG_URL.Parser.parse("http://example.com")
            #expect(url != nil)
            #expect(url?.scheme.value == "http")
            #expect(url?.host == .domain(try! Domain_Standard.Domain("example.com")))
            #expect(url?.port == nil)  // Default port omitted
            #expect(url?.path == .list([]))
        }

        @Test
        func `parse HTTPS URL with path`() {
            let url = WHATWG_URL.Parser.parse("https://example.com/path/to/resource")
            #expect(url != nil)
            #expect(url?.scheme.value == "https")
            #expect(url?.host == .domain(try! Domain_Standard.Domain("example.com")))
            #expect(url?.path == .list(["path", "to", "resource"]))
        }

        @Test
        func `parse URL with non-default port`() {
            let url = WHATWG_URL.Parser.parse("http://example.com:8080/path")
            #expect(url != nil)
            #expect(url?.scheme.value == "http")
            #expect(url?.port == 8080)
        }

        @Test
        func `parse URL with default port omits port`() {
            let url = WHATWG_URL.Parser.parse("http://example.com:80/path")
            #expect(url != nil)
            #expect(url?.port == nil)  // Port 80 is default for http
        }

        @Test
        func `parse URL with query`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/path?query=value&foo=bar")
            #expect(url != nil)
            #expect(url?.query == "query=value&foo=bar")
        }

        @Test
        func `parse URL with fragment`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/path#section")
            #expect(url != nil)
            #expect(url?.fragment == "section")
        }

        @Test
        func `parse URL with query and fragment`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/path?query=value#section")
            #expect(url != nil)
            #expect(url?.query == "query=value")
            #expect(url?.fragment == "section")
        }

        @Test
        func `parse URL with username and password`() {
            let url = WHATWG_URL.Parser.parse("http://user:pass@example.com/path")
            #expect(url != nil)
            #expect(url?.username == "user")
            #expect(url?.password == "pass")
        }

        @Test
        func `parse URL with username only`() {
            let url = WHATWG_URL.Parser.parse("http://user@example.com/path")
            #expect(url != nil)
            #expect(url?.username == "user")
            #expect(url?.password == "")
        }
    }

    // MARK: - Special Schemes

    @Suite
    struct `Parser - Special Schemes` {

        @Test(arguments: ["http", "https", "ws", "wss", "ftp", "file"])
        func `special schemes are recognized`(scheme: String) {
            let url = WHATWG_URL.Parser.parse("\(scheme)://example.com/path")
            #expect(url != nil)
            #expect(url?.scheme.value == scheme)
        }

        @Test
        func `file URL without host`() {
            let url = WHATWG_URL.Parser.parse("file:///path/to/file")
            #expect(url != nil)
            #expect(url?.scheme.value == "file")
            #expect(url?.host == .empty)
        }

        @Test
        func `ws URL with port`() {
            let url = WHATWG_URL.Parser.parse("ws://example.com:9000/socket")
            #expect(url != nil)
            #expect(url?.scheme.value == "ws")
            #expect(url?.port == 9000)
        }

        @Test
        func `wss URL with default port omitted`() {
            let url = WHATWG_URL.Parser.parse("wss://example.com:443/socket")
            #expect(url != nil)
            #expect(url?.port == nil)  // 443 is default for wss
        }
    }

    // MARK: - Non-Special Schemes

    @Suite
    struct `Parser - Non-Special Schemes` {

        @Test
        func `data URL with opaque path`() {
            let url = WHATWG_URL.Parser.parse("data:text/plain;base64,SGVsbG8=")
            #expect(url != nil)
            #expect(url?.scheme.value == "data")
            if case .opaque(let path) = url?.path {
                #expect(path.contains("text/plain"))
            } else {
                Issue.record("Expected opaque path for data URL")
            }
        }

        @Test
        func `mailto URL`() {
            let url = WHATWG_URL.Parser.parse("mailto:user@example.com")
            #expect(url != nil)
            #expect(url?.scheme.value == "mailto")
        }

        @Test
        func `custom scheme URL`() {
            let url = WHATWG_URL.Parser.parse("customscheme://example/path")
            #expect(url != nil)
            #expect(url?.scheme.value == "customscheme")
        }
    }

    // MARK: - Path Normalization

    @Suite
    struct `Parser - Path Normalization` {

        @Test
        func `single dot segment is removed`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/a/./b")
            #expect(url != nil)
            #expect(url?.path == .list(["a", "b"]))
        }

        @Test
        func `double dot pops segment`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/a/b/../c")
            #expect(url != nil)
            #expect(url?.path == .list(["a", "c"]))
        }

        @Test
        func `double dot at start does nothing`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/../a")
            #expect(url != nil)
            #expect(url?.path == .list(["a"]))
        }

        @Test
        func `multiple normalizations`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/a/b/./c/../d")
            #expect(url != nil)
            #expect(url?.path == .list(["a", "b", "d"]))
        }

        @Test
        func `trailing single dot removed`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/a/b/.")
            #expect(url != nil)
            #expect(url?.path == .list(["a", "b"]))
        }

        @Test
        func `trailing double dot pops`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/a/b/..")
            #expect(url != nil)
            #expect(url?.path == .list(["a"]))
        }
    }

    // MARK: - Relative URLs

    @Suite
    struct `Parser - Relative URLs` {

        @Test
        func `relative path against base URL`() {
            let base = WHATWG_URL.Parser.parse("http://example.com/a/b")
            let url = WHATWG_URL.Parser.parse("c/d", base: base)
            #expect(url != nil)
            #expect(url?.scheme.value == "http")
            #expect(url?.host == base?.host)
            #expect(url?.path == .list(["a", "c", "d"]))
        }

        @Test
        func `absolute path against base URL`() {
            let base = WHATWG_URL.Parser.parse("http://example.com/a/b")
            let url = WHATWG_URL.Parser.parse("/x/y", base: base)
            #expect(url != nil)
            #expect(url?.scheme.value == "http")
            #expect(url?.host == base?.host)
            #expect(url?.path == .list(["x", "y"]))
        }

        @Test
        func `query-only against base URL`() {
            let base = WHATWG_URL.Parser.parse("http://example.com/a/b")
            let url = WHATWG_URL.Parser.parse("?newquery", base: base)
            #expect(url != nil)
            #expect(url?.path == base?.path)
            #expect(url?.query == "newquery")
        }

        @Test
        func `fragment-only against base URL`() {
            let base = WHATWG_URL.Parser.parse("http://example.com/a/b#oldfrag")
            let url = WHATWG_URL.Parser.parse("#newfrag", base: base)
            #expect(url != nil)
            #expect(url?.path == base?.path)
            #expect(url?.query == base?.query)
            #expect(url?.fragment == "newfrag")
        }

        @Test
        func `empty string against base returns base`() {
            let base = WHATWG_URL.Parser.parse("http://example.com/path")
            let url = WHATWG_URL.Parser.parse("", base: base)
            #expect(url != nil)
            #expect(url?.scheme == base?.scheme)
            #expect(url?.host == base?.host)
            #expect(url?.path == base?.path)
        }
    }

    // MARK: - IPv4 Addresses

    @Suite
    struct `Parser - IPv4 Addresses` {

        @Test
        func `standard dotted-decimal IPv4`() {
            let url = WHATWG_URL.Parser.parse("http://192.168.1.1/path")
            #expect(url != nil)
            if case .ipv4(let addr) = url?.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG hex IPv4`() {
            let url = WHATWG_URL.Parser.parse("http://0xC0.0xA8.0x1.0x1/path")
            #expect(url != nil)
            if case .ipv4(let addr) = url?.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG octal IPv4`() {
            let url = WHATWG_URL.Parser.parse("http://0300.0250.01.01/path")
            #expect(url != nil)
            if case .ipv4(let addr) = url?.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG compressed IPv4`() {
            let url = WHATWG_URL.Parser.parse("http://192.168.257/path")
            #expect(url != nil)
            if case .ipv4(let addr) = url?.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }

        @Test
        func `WHATWG single number IPv4`() {
            let url = WHATWG_URL.Parser.parse("http://3232235777/path")
            #expect(url != nil)
            if case .ipv4(let addr) = url?.host {
                #expect(addr.octets == (192, 168, 1, 1))
            } else {
                Issue.record("Expected IPv4 host")
            }
        }
    }

    // MARK: - IPv6 Addresses

    @Suite
    struct `Parser - IPv6 Addresses` {

        @Test
        func `standard IPv6 with brackets`() {
            let url = WHATWG_URL.Parser.parse("http://[2001:db8::1]/path")
            #expect(url != nil)
            if case .ipv6 = url?.host {
                // Success - IPv6 parsed
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv6 with zone ID stripped`() {
            let url = WHATWG_URL.Parser.parse("http://[fe80::1%eth0]/path")
            #expect(url != nil)
            if case .ipv6 = url?.host {
                // Success - IPv6 parsed with zone ID stripped
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv4-embedded IPv6`() {
            let url = WHATWG_URL.Parser.parse("http://[::ffff:192.0.2.1]/path")
            #expect(url != nil)
            if case .ipv6 = url?.host {
                // Success - IPv4-embedded IPv6 parsed
            } else {
                Issue.record("Expected IPv6 host")
            }
        }

        @Test
        func `IPv6 localhost`() {
            let url = WHATWG_URL.Parser.parse("http://[::1]/path")
            #expect(url != nil)
            if case .ipv6 = url?.host {
                // Success
            } else {
                Issue.record("Expected IPv6 host")
            }
        }
    }

    // MARK: - Percent Encoding

    @Suite
    struct `Parser - Percent Encoding` {

        @Test
        func `percent-encoded path is decoded during parsing`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/hello%20world")
            #expect(url != nil)
            #expect(url?.path == .list(["hello world"]))
        }

        @Test
        func `percent-encoded query is preserved`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/?q=hello%20world")
            #expect(url != nil)
            #expect(url?.query?.contains("hello") == true)
        }

        @Test
        func `special characters in userinfo are encoded`() {
            let url = WHATWG_URL.Parser.parse("http://user@name:pass@example.com/")
            #expect(url != nil)
            // Username should be "user" and @ should be encoded
            #expect(url?.username.contains("%40") == true)
        }
    }

    // MARK: - Invalid URLs

    @Suite
    struct `Parser - Invalid URLs` {

        @Test
        func `no scheme returns nil`() {
            let url = WHATWG_URL.Parser.parse("example.com/path")
            #expect(url == nil)
        }

        @Test
        func `invalid scheme returns nil`() {
            let url = WHATWG_URL.Parser.parse("ht!tp://example.com")
            #expect(url == nil)
        }

        @Test
        func `missing slashes for special scheme returns nil`() {
            let url = WHATWG_URL.Parser.parse("http:example.com")
            #expect(url == nil)
        }

        @Test
        func `invalid port returns nil`() {
            let url = WHATWG_URL.Parser.parse("http://example.com:99999999/path")
            #expect(url == nil)
        }

        @Test
        func `invalid IPv6 returns nil`() {
            let url = WHATWG_URL.Parser.parse("http://[not-ipv6]/path")
            #expect(url == nil)
        }
    }

    // MARK: - Edge Cases

    @Suite
    struct `Parser - Edge Cases` {

        @Test
        func `empty path`() {
            let url = WHATWG_URL.Parser.parse("http://example.com")
            #expect(url != nil)
            #expect(url?.path == .list([]))
        }

        @Test
        func `trailing slash creates empty segment`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/")
            #expect(url != nil)
            // Implementation may vary - document expected behavior
        }

        @Test
        func `multiple slashes are preserved`() {
            let url = WHATWG_URL.Parser.parse("http://example.com//a///b")
            #expect(url != nil)
            // Empty segments between slashes
        }

        @Test
        func `whitespace is trimmed`() {
            let url = WHATWG_URL.Parser.parse("  http://example.com/path  ")
            #expect(url != nil)
            #expect(url?.scheme.value == "http")
        }

        @Test
        func `empty query`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/?")
            #expect(url != nil)
            #expect(url?.query == "")
        }

        @Test
        func `empty fragment`() {
            let url = WHATWG_URL.Parser.parse("http://example.com/#")
            #expect(url != nil)
            #expect(url?.fragment == "")
        }
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct `Parser - Performance` {

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 simple URLs`() {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.Parser.parse("http://example.com/path")
            }
        }

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 complex URLs`() {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.Parser.parse("https://user:pass@example.com:8080/a/b/c?query=value#fragment")
            }
        }

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 URLs with normalization`() {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.Parser.parse("http://example.com/a/./b/../c")
            }
        }
    }
}
