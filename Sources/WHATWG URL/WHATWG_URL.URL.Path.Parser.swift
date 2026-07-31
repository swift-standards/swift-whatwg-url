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

// WHATWG_URL.URL.Path.Parser.swift
// swift-whatwg-url

public import Byte_Parser_Primitives
public import Parser_Primitives

extension WHATWG_URL.URL.Path {
    /// Parser witness carrying the out-of-band parse CONTEXT a path needs — whether
    /// the path is opaque (non-special scheme) or a segment list — as a stored VALUE.
    ///
    /// ## [FAM-012] §11 — context as a parser-witness VALUE
    ///
    /// Path parsing is context-dependent: the same raw bytes decode differently
    /// depending on `Path.Context.kind`. Per the serialize/parse codec-attachment
    /// model §11, that context is **NOT** an `associatedtype Context` on a flat parse
    /// marker ([FAM-001]); it is carried by a **witness VALUE the caller constructs
    /// with the context and passes in** (the serde `DeserializeSeed` shape):
    ///
    /// ```swift
    /// let path = try WHATWG_URL.URL.Path.parse(
    ///     from: bytes,
    ///     parser: WHATWG_URL.URL.Path.Parser(.opaque)
    /// )
    /// ```
    ///
    /// The witness conforms to the ecosystem `Parser.`Protocol`` so the context lives
    /// on the witness value while the flat parse marker stays context-free. The
    /// concrete reader body is preserved in `WHATWG_URL.URL.Path.init(ascii:in:)`,
    /// which this witness's `parse` drains the cursor into and delegates to.
    public struct Parser: Parser_Primitives.Parser.`Protocol`, Sendable {
        /// The parse context (opaque vs. list).
        public let context: WHATWG_URL.URL.Path.Context

        /// Builds the parser witness with its parse context.
        public init(_ context: WHATWG_URL.URL.Path.Context) {
            self.context = context
        }
    }
}

extension WHATWG_URL.URL.Path.Parser {
    public typealias Body = Never

    /// Parses a path from the byte cursor `input`, consuming it.
    ///
    /// [FAM-012] `Parser.`Protocol`` cursor-form leaf: drains the whole byte
    /// cursor (path is a whole-buffer grammar) and runs the concrete reader with
    /// this witness's stored `context`.
    public borrowing func parse(
        _ input: inout Byte.Input
    ) throws(WHATWG_URL.URL.Path.Error) -> WHATWG_URL.URL.Path {
        var bytes: [Byte] = []
        while let byte = input.next() {
            bytes.append(byte)
        }
        return try WHATWG_URL.URL.Path(ascii: bytes, in: context)
    }
}

extension WHATWG_URL.URL.Path {
    /// Parses a path from `bytes`, with the parse CONTEXT carried by the `parser`
    /// witness VALUE ([FAM-012] §11 — the ergonomic context-bearing entry).
    ///
    /// Builds the canonical `Byte.Input` cursor from `bytes` and delegates to the
    /// witness's `Parser.`Protocol`` cursor `parse(_:)`.
    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes,
        parser: Parser
    ) throws(Error) -> WHATWG_URL.URL.Path
    where Bytes.Element == Byte {
        var input = Byte.Input(bytes)
        return try parser.parse(&input)
    }
}
