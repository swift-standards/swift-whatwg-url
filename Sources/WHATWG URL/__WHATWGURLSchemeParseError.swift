//
//  __WHATWGURLSchemeParseError.swift
//  swift-whatwg-url
//

// MARK: - Hoisted error (module level)
//
// `WHATWG_URL.URL.Scheme.Parse<Input>`'s error never uses `Input` — nesting it
// in the generic type makes the `@error` SIL result accidentally generic,
// which can trip `FunctionSignatureOpts` under `-O -enable-default-cmo`
// (swiftlang/swift#89617). Hoisted to non-generic module scope per
// [API-ERR-009]; `Parse<Input>.Error` keeps resolving via the typealias on
// the generic type.

/// Hoisted implementation of `WHATWG_URL.URL.Scheme.Parse`'s error.
///
/// - Note: Use `WHATWG_URL.URL.Scheme.Parse<Input>.Error`, not this type directly.
public enum __WHATWGURLSchemeParseError: Swift.Error, Sendable, Equatable {
    case expectedAlpha
    case expectedColon
}
