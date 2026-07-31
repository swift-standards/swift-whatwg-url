// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

extension WHATWG_URL.URL {
    /// Internal builder for constructing URLs during parsing
    struct Builder {
        var scheme: Scheme?
        var username: String = ""
        var password: String = ""
        var host: Host?
        var port: UInt16?
        var path: Path = .list([])
        var query: String?
        var fragment: String?
    }
}

extension WHATWG_URL.URL.Builder {
    mutating func pushPathSegment(_ segment: String) {
        switch path {
        case .list(var segments):
            segments.append(segment)
            path = .list(segments)
        case .opaque:
            break
        }
    }

    mutating func popPathSegment() {
        switch path {
        case .list(var segments):
            if !segments.isEmpty {
                segments.removeLast()
            }
            path = .list(segments)
        case .opaque:
            break
        }
    }

    func build() throws(WHATWG_URL.URL.Error) -> WHATWG_URL.URL {
        guard let scheme = scheme else {
            throw .invalidScheme("")
        }

        return WHATWG_URL.URL(
            scheme: scheme,
            username: username,
            password: password,
            host: host,
            port: port,
            path: path,
            query: query,
            fragment: fragment
        )
    }
}
