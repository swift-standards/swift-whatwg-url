// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// FAM-012 Tests.swift
// swift-whatwg-url
//
// [FAM-012] format-sibling drain of WHATWG_Form_URL_Encoded.EncodedString — an
// ASCII-only conformer (percent-encoded text; its byte view is a text projection,
// not a wire codec, so there is no `Binary.Serializable` peer). Exercises the flat
// `ASCII.Serializable` verb and the free-standing `ASCII.Parseable` init.

import ASCII_Serializer_Primitives
import Testing

@testable import WHATWG_Form_URL_Encoded

extension WHATWG_Form_URL_Encoded.EncodedString {
    @Suite("WHATWG Form URL Encoded [FAM-012] Format Siblings")
    struct Test {

        @Test func `EncodedString ASCII serialize + parse round-trip`() throws {
            let encoded = WHATWG_Form_URL_Encoded.EncodedString(encoding: "Hello World!")
            #expect(encoded.description == "Hello+World%21")

            var codes: [ASCII.Code] = []
            WHATWG_Form_URL_Encoded.EncodedString.serialize(encoded, into: &codes)
            #expect(String(decoding: codes.map(\.byte), as: UTF8.self) == "Hello+World%21")

            // Free-standing ASCII.Parseable init: interprets bytes as already-encoded (total).
            let reparsed = WHATWG_Form_URL_Encoded.EncodedString(ascii: codes.map(\.byte))
            #expect(reparsed == encoded)
            #expect(reparsed.description == "Hello+World%21")
        }
    }
}
