import Testing
@testable import WHATWG_URL
import Domain_Standard

@Suite("WHATWG URL Tests")
struct URLTests {

    @Test("URL structure initialization")
    func urlStructure() throws {
        let url = WHATWG_URL(
            scheme: "https",
            username: "user",
            password: "pass",
            host: .domain(try Domain("example.com")),
            port: 8080,
            path: .list(["path", "to", "resource"]),
            query: "key=value",
            fragment: "section"
        )

        #expect(url.scheme == "https")
        #expect(url.username == "user")
        #expect(url.password == "pass")
        #expect(url.host == .domain(try Domain("example.com")))
        #expect(url.port == 8080)
        #expect(url.path == .list(["path", "to", "resource"]))
        #expect(url.query == "key=value")
        #expect(url.fragment == "section")
    }

    @Test("URL serialization with all components")
    func urlSerializationComplete() throws {
        let url = WHATWG_URL(
            scheme: "https",
            username: "user",
            password: "pass",
            host: .domain(try Domain("example.com")),
            port: 8080,
            path: .list(["path", "to", "resource"]),
            query: "key=value",
            fragment: "section"
        )

        let href = url.href
        #expect(href == "https://user:pass@example.com:8080/path/to/resource?key=value#section")
    }

    @Test("URL serialization without credentials")
    func urlSerializationNoCredentials() throws {
        let url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            path: .list(["path"])
        )

        let href = url.href
        #expect(href == "https://example.com/path")
    }

    @Test("URL serialization with default port omitted")
    func urlSerializationDefaultPort() throws {
        // HTTPS default port is 443
        let url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            port: 443,
            path: .list(["path"])
        )

        let href = url.href
        #expect(href == "https://example.com/path")
    }

    @Test("URL serialization with non-default port")
    func urlSerializationNonDefaultPort() throws {
        let url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            port: 8443,
            path: .list(["path"])
        )

        let href = url.href
        #expect(href == "https://example.com:8443/path")
    }

    @Test("WHATWG_URL.SearchParams parsing")
    func searchParamsParsing() throws {
        let params = WHATWG_URL.SearchParams("name=John+Doe&email=john%40example.com&age=30")

        #expect(params.get("name") == "John Doe")
        #expect(params.get("email") == "john@example.com")
        #expect(params.get("age") == "30")
        #expect(params.get("missing") == nil)
    }

    @Test("WHATWG_URL.SearchParams building")
    func searchParamsBuilding() throws {
        var params = WHATWG_URL.SearchParams()
        params.append("name", "John Doe")
        params.append("email", "john@example.com")

        let query = params.toString()
        #expect(query == "name=John+Doe&email=john%40example.com")
    }

    @Test("WHATWG_URL.SearchParams set and delete")
    func searchParamsSetDelete() throws {
        var params = WHATWG_URL.SearchParams()
        params.append("key", "value1")
        params.append("key", "value2")

        #expect(params.getAll("key") == ["value1", "value2"])

        params.set("key", "newvalue")
        #expect(params.get("key") == "newvalue")
        #expect(params.getAll("key") == ["newvalue"])

        params.delete("key")
        #expect(params.get("key") == nil)
    }

    @Test("URLHost IPv4 serialization")
    func hostIPv4() throws {
        let host = WHATWG_URL.Host.ipv4(192, 168, 1, 1)
        #expect(host.serialized == "192.168.1.1")
    }

    @Test("URLHost domain serialization")
    func hostDomain() throws {
        let host = WHATWG_URL.Host.domain(try Domain("example.com"))
        #expect(host.serialized == "example.com")
    }

    @Test("URLPath list serialization")
    func pathList() throws {
        let path = WHATWG_URL.Path.list(["path", "to", "resource"])
        #expect(path.serialized == "/path/to/resource")
    }

    @Test("URLPath empty list serialization")
    func pathEmptyList() throws {
        let path = WHATWG_URL.Path.emptyList
        #expect(path.serialized == "")
    }

    @Test("URLPath opaque serialization")
    func pathOpaque() throws {
        let path = WHATWG_URL.Path.opaque("opaque-data")
        #expect(path.serialized == "opaque-data")
    }

    @Test("URLScheme special schemes")
    func specialSchemes() throws {
        #expect(WHATWG_URL.Scheme.isSpecial("http"))
        #expect(WHATWG_URL.Scheme.isSpecial("https"))
        #expect(WHATWG_URL.Scheme.isSpecial("ftp"))
        #expect(WHATWG_URL.Scheme.isSpecial("file"))
        #expect(WHATWG_URL.Scheme.isSpecial("ws"))
        #expect(WHATWG_URL.Scheme.isSpecial("wss"))
        #expect(!WHATWG_URL.Scheme.isSpecial("mailto"))
        #expect(!WHATWG_URL.Scheme.isSpecial("data"))
    }

    @Test("URLScheme default ports")
    func defaultPorts() throws {
        #expect(WHATWG_URL.Scheme.defaultPort(for: "http") == 80)
        #expect(WHATWG_URL.Scheme.defaultPort(for: "https") == 443)
        #expect(WHATWG_URL.Scheme.defaultPort(for: "ftp") == 21)
        #expect(WHATWG_URL.Scheme.defaultPort(for: "ws") == 80)
        #expect(WHATWG_URL.Scheme.defaultPort(for: "wss") == 443)
        #expect(WHATWG_URL.Scheme.defaultPort(for: "file") == nil)
    }

    @Test("URL origin for special schemes")
    func urlOrigin() throws {
        let url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            port: 443,
            path: .list(["path"])
        )

        #expect(url.origin == "https://example.com")
    }

    @Test("URL convenience properties")
    func urlConvenienceProperties() throws {
        let url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            path: .list(["path"]),
            query: "key=value",
            fragment: "section"
        )

        #expect(url.protocol == "https:")
        #expect(url.hostname == "example.com")
        #expect(url.pathname == "/path")
        #expect(url.search == "?key=value")
        #expect(url.hash == "#section")
    }

    @Test("URL searchParams getter and setter")
    func urlSearchParams() throws {
        var url = WHATWG_URL(
            scheme: "https",
            host: .domain(try Domain("example.com")),
            path: .list(["path"]),
            query: "name=John&age=30"
        )

        let params = url.searchParams
        #expect(params.get("name") == "John")
        #expect(params.get("age") == "30")

        var newParams = WHATWG_URL.SearchParams()
        newParams.append("email", "john@example.com")
        url.searchParams = newParams

        #expect(url.query == "email=john%40example.com")
    }
}
