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

// WHATWG_URL.URL.Host.Parser.swift
// swift-whatwg-url

public import Byte_Parser_Primitives
public import Parser_Primitives

extension WHATWG_URL.URL.Host {
    /// Parser witness carrying the out-of-band parse CONTEXT a host needs — whether
    /// the URL scheme is "special" (`Host.Context.isSpecial`) — as a stored VALUE.
    ///
    /// ## [FAM-012] §11 — context as a parser-witness VALUE
    ///
    /// Host parsing is context-dependent: a special scheme parses hosts as domains
    /// (with IDNA) / IPv4, a non-special scheme as opaque. Per the serialize/parse
    /// codec-attachment model §11, that context is **NOT** an `associatedtype Context`
    /// on a flat parse marker ([FAM-001]); it is carried by a **witness VALUE the
    /// caller constructs with the context and passes in** (the serde `DeserializeSeed`
    /// shape):
    ///
    /// ```swift
    /// let host = try WHATWG_URL.URL.Host.parse(
    ///     from: bytes,
    ///     parser: WHATWG_URL.URL.Host.Parser(.special)
    /// )
    /// ```
    ///
    /// The witness conforms to the ecosystem `Parser.`Protocol`` so the context lives
    /// on the witness value while the flat parse marker stays context-free. The
    /// concrete reader body is preserved in `WHATWG_URL.URL.Host.init(ascii:in:)`,
    /// which this witness's `parse` drains the cursor into and delegates to.
    public struct Parser: Parser_Primitives.Parser.`Protocol`, Sendable {
        public typealias Input = Byte.Input
        public typealias Output = WHATWG_URL.URL.Host
        public typealias Failure = WHATWG_URL.URL.Host.Error
        public typealias Body = Never

        /// The parse context (special vs. non-special scheme).
        public let context: WHATWG_URL.URL.Host.Context

        /// Builds the parser witness with its parse context.
        public init(_ context: WHATWG_URL.URL.Host.Context) {
            self.context = context
        }

        /// Parses a host from the byte cursor `input`, consuming it.
        ///
        /// [FAM-012] `Parser.`Protocol`` cursor-form leaf: drains the whole byte
        /// cursor (host is a whole-buffer grammar) and runs the concrete reader with
        /// this witness's stored `context`.
        public borrowing func parse(
            _ input: inout Byte.Input
        ) throws(WHATWG_URL.URL.Host.Error) -> WHATWG_URL.URL.Host {
            var bytes: [Byte] = []
            while !input.isEmpty {
                guard let byte = try? input.advance() else { break }
                bytes.append(byte)
            }
            return try WHATWG_URL.URL.Host(ascii: bytes, in: context)
        }
    }
}

extension WHATWG_URL.URL.Host {
    /// Parses a host from `bytes`, with the parse CONTEXT carried by the `parser`
    /// witness VALUE ([FAM-012] §11 — the ergonomic context-bearing entry).
    ///
    /// Builds the canonical `Byte.Input` cursor from `bytes` and delegates to the
    /// witness's `Parser.`Protocol`` cursor `parse(_:)`.
    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes,
        parser: Parser
    ) throws(Error) -> WHATWG_URL.URL.Host
    where Bytes.Element == Byte {
        var input = Byte.Input(bytes)
        return try parser.parse(&input)
    }
}
