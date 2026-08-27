import ASCII_Serializer
import Domain_Standard
import RFC_791
import Testing

@testable import WHATWG_URL

private func bytes(_ string: String) -> [Byte] { string.utf8.map { Byte($0) } }

private func ascii(_ codes: [ASCII.Code]) -> String {
    String(decoding: codes.map(\.byte), as: UTF8.self)
}

@Suite("WHATWG URL [FAM-012] Format Siblings")
struct WHATWGURLFAM012Tests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension WHATWGURLFAM012Tests.Unit {
    @Test func `Scheme ASCII serialize + parse round-trip`() throws {
        let scheme = try WHATWG_URL.URL.Scheme("https")
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Scheme.serialize(scheme, into: &codes)
        #expect(ascii(codes) == "https")
        let reparsed = try WHATWG_URL.URL.Scheme(ascii: codes.map(\.byte))
        #expect(reparsed == scheme)
        #expect(scheme.description == "https")
    }

    @Test func `Href ASCII serialize + parse round-trip`() throws {
        let url = WHATWG_URL.URL(
            scheme: .https,
            host: .domain(try Domain("example.com")),
            path: .list(["a", "b"])
        )
        let href = url.href
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Href.serialize(href, into: &codes)
        #expect(ascii(codes) == "https://example.com/a/b")
        let reparsed = try WHATWG_URL.URL.Href(ascii: codes.map(\.byte))
        #expect(reparsed == href)
    }

    @Test func `Host domain ASCII verb`() throws {
        let host = WHATWG_URL.URL.Host.domain(try Domain("example.com"))
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Host.serialize(host, into: &codes)
        #expect(ascii(codes) == "example.com")
    }

    @Test func `Host IPv4 ASCII verb composes rfc-791 dotted-decimal`() throws {
        let host = WHATWG_URL.URL.Host.ipv4(RFC_791.IPv4.Address(192, 168, 1, 1))
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Host.serialize(host, into: &codes)
        #expect(ascii(codes) == "192.168.1.1")
    }
}

extension WHATWGURLFAM012Tests.`Edge Case` {
    @Test func `Path list ASCII serialize verb`() throws {
        let path = WHATWG_URL.URL.Path.list(["path", "to", "resource"])
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Path.serialize(path, into: &codes)
        #expect(ascii(codes) == "/path/to/resource")

        var empty: [ASCII.Code] = []
        WHATWG_URL.URL.Path.serialize(.emptyList, into: &empty)
        #expect(empty.isEmpty)
    }
}

extension WHATWGURLFAM012Tests.Integration {
    @Test func `Host IPv6 ASCII verb composes rfc-5952 canonical + brackets`() throws {

        let host = try WHATWG_URL.URL.Host.parse(from: bytes("[::1]"), parser: .init(.special))
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.Host.serialize(host, into: &codes)
        #expect(ascii(codes) == "[::1]")

        let host2 = try WHATWG_URL.URL.Host.parse(
            from: bytes("[2001:db8::1]"),
            parser: .init(.special)
        )
        var codes2: [ASCII.Code] = []
        WHATWG_URL.URL.Host.serialize(host2, into: &codes2)
        #expect(ascii(codes2) == "[2001:db8::1]")
    }

    @Test func `Host parse witness threads the special-scheme context`() throws {

        let special = try WHATWG_URL.URL.Host.parse(
            from: bytes("example.com"),
            parser: .init(.special)
        )
        #expect(special == .domain(try Domain("example.com")))
        let opaque = try WHATWG_URL.URL.Host.parse(
            from: bytes("example.com"),
            parser: .init(.nonSpecial)
        )
        #expect(opaque == .opaque("example.com"))
    }

    @Test func `Path list parse witness threads the list context`() throws {

        let parsed = try WHATWG_URL.URL.Path.parse(from: bytes("a/b/c"), parser: .init(.list))
        #expect(parsed == .list(["a", "b", "c"]))
    }

    @Test func `Path opaque parse witness threads the isOpaque context`() throws {
        let opaque = try WHATWG_URL.URL.Path.parse(
            from: bytes("opaque-data"),
            parser: .init(.opaque)
        )
        #expect(opaque == .opaque("opaque-data"))
    }

    @Test func `URL ASCII serialize + parse witness round-trip`() throws {
        let url = WHATWG_URL.URL(
            scheme: .https,
            host: .domain(try Domain("example.com")),
            port: 8443,
            path: .list(["p"]),
            query: "k=v",
            fragment: "f"
        )
        var codes: [ASCII.Code] = []
        WHATWG_URL.URL.serialize(url, into: &codes)
        #expect(ascii(codes) == "https://example.com:8443/p?k=v#f")
        let reparsed = try WHATWG_URL.URL.parse(from: codes.map(\.byte), parser: .init(.none))
        #expect(reparsed.href == url.href)
    }

    @Test func `URL parse witness threads the base-URL context (relative resolution)`() throws {
        let base = try WHATWG_URL.URL("https://example.com/a/b")
        let resolved = try WHATWG_URL.URL.parse(
            from: bytes("/other"),
            parser: .init(WHATWG_URL.URL.ParsingContext(base: base))
        )
        #expect(resolved.href.value == "https://example.com/other")
    }
}
