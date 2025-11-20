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

    @Test("URLSearchParams parsing")
    func searchParamsParsing() throws {
        let params = URLSearchParams("name=John+Doe&email=john%40example.com&age=30")

        #expect(params.get("name") == "John Doe")
        #expect(params.get("email") == "john@example.com")
        #expect(params.get("age") == "30")
        #expect(params.get("missing") == nil)
    }

    @Test("URLSearchParams building")
    func searchParamsBuilding() throws {
        var params = URLSearchParams()
        params.append("name", "John Doe")
        params.append("email", "john@example.com")

        let query = params.toString()
        #expect(query == "name=John+Doe&email=john%40example.com")
    }

    @Test("URLSearchParams set and delete")
    func searchParamsSetDelete() throws {
        var params = URLSearchParams()
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
        let host = URLHost.ipv4(192, 168, 1, 1)
        #expect(host.serialized == "192.168.1.1")
    }

    @Test("URLHost domain serialization")
    func hostDomain() throws {
        let host = URLHost.domain(try Domain("example.com"))
        #expect(host.serialized == "example.com")
    }

    @Test("URLPath list serialization")
    func pathList() throws {
        let path = URLPath.list(["path", "to", "resource"])
        #expect(path.serialized == "/path/to/resource")
    }

    @Test("URLPath empty list serialization")
    func pathEmptyList() throws {
        let path = URLPath.emptyList
        #expect(path.serialized == "")
    }

    @Test("URLPath opaque serialization")
    func pathOpaque() throws {
        let path = URLPath.opaque("opaque-data")
        #expect(path.serialized == "opaque-data")
    }

    @Test("URLScheme special schemes")
    func specialSchemes() throws {
        #expect(URLScheme.isSpecial("http"))
        #expect(URLScheme.isSpecial("https"))
        #expect(URLScheme.isSpecial("ftp"))
        #expect(URLScheme.isSpecial("file"))
        #expect(URLScheme.isSpecial("ws"))
        #expect(URLScheme.isSpecial("wss"))
        #expect(!URLScheme.isSpecial("mailto"))
        #expect(!URLScheme.isSpecial("data"))
    }

    @Test("URLScheme default ports")
    func defaultPorts() throws {
        #expect(URLScheme.defaultPort(for: "http") == 80)
        #expect(URLScheme.defaultPort(for: "https") == 443)
        #expect(URLScheme.defaultPort(for: "ftp") == 21)
        #expect(URLScheme.defaultPort(for: "ws") == 80)
        #expect(URLScheme.defaultPort(for: "wss") == 443)
        #expect(URLScheme.defaultPort(for: "file") == nil)
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

        var newParams = URLSearchParams()
        newParams.append("email", "john@example.com")
        url.searchParams = newParams

        #expect(url.query == "email=john%40example.com")
    }
}
