import Testing

@testable import WHATWG_URL

extension `Performance Tests` {
    @Suite
    struct `URL - Performance` {

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 simple URLs`() throws {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.URL(parsing: "http://example.com/path")
            }
        }

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 complex URLs`() throws {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.URL(
                    parsing: "https://user:pass@example.com:8080/a/b/c?query=value#fragment"
                )
            }
        }

        @Test(.timed(threshold: .milliseconds(5000)))
        func `parse 10000 URLs with normalization`() throws {
            for _ in 0..<10_000 {
                _ = WHATWG_URL.URL(parsing: "http://example.com/a/./b/../c")
            }
        }
    }
}
