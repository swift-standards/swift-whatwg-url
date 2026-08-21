public import ASCII_Serializer_Primitives
import Domain_Standard
import RFC_5952
import RFC_791

extension WHATWG_URL.URL {

    public struct ParsingContext: Sendable {

        public let base: WHATWG_URL.URL?

        public init(base: WHATWG_URL.URL? = nil) {
            self.base = base
        }
    }
}

extension WHATWG_URL.URL.ParsingContext {

    public static let none = WHATWG_URL.URL.ParsingContext(base: nil)
}

extension WHATWG_URL.URL: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ url: WHATWG_URL.URL,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {

        Scheme.serialize(url.scheme, into: &buffer)
        buffer.append(ASCII.Code.colon)

        if let host = url.host {
            buffer.append(ASCII.Code.solidus)
            buffer.append(ASCII.Code.solidus)

            if !url.username.isEmpty || !url.password.isEmpty {
                for byte in url.username.utf8 { buffer.append(ASCII.Code(byte)) }
                if !url.password.isEmpty {
                    buffer.append(ASCII.Code.colon)
                    for byte in url.password.utf8 { buffer.append(ASCII.Code(byte)) }
                }
                buffer.append(ASCII.Code.commercialAt)
            }

            Host.serialize(host, into: &buffer)

            if let port = url.port, Scheme.defaultPort(for: url.scheme) != port {
                buffer.append(ASCII.Code.colon)
                for byte in String(port).utf8 { buffer.append(ASCII.Code(byte)) }
            }
        }

        Path.serialize(url.path, into: &buffer)

        if let query = url.query {
            buffer.append(ASCII.Code.questionMark)
            for byte in query.utf8 { buffer.append(ASCII.Code(byte)) }
        }

        if let fragment = url.fragment {
            buffer.append(ASCII.Code.numberSign)
            for byte in fragment.utf8 { buffer.append(ASCII.Code(byte)) }
        }
    }
}

extension WHATWG_URL.URL {

    public init<Bytes: Swift.Collection>(
        ascii bytes: Bytes,
        in context: ParsingContext
    ) throws(Error) where Bytes.Element == Byte {
        var url = Builder()
        var state = State.schemeStart
        var buffer = ""
        var atSignSeen = false

        let array = [UInt8](bytes)

        let horizontalTab: UInt8 = 0x09
        var startIndex = 0
        var endIndex = array.count
        while startIndex < endIndex
            && (array[startIndex] == UInt8.ascii.sp || array[startIndex] == horizontalTab)
        {
            startIndex += 1
        }
        while endIndex > startIndex
            && (array[endIndex - 1] == UInt8.ascii.sp || array[endIndex - 1] == horizontalTab)
        {
            endIndex -= 1
        }

        let trimmed = Array(array[startIndex..<endIndex])

        guard !trimmed.isEmpty else {

            if let base = context.base {
                self = base
                return
            }
            throw .emptyInput
        }

        var pointer = 0

        parsing: while pointer <= trimmed.count {
            let c: UInt8? = pointer < trimmed.count ? trimmed[pointer] : nil

            switch state {
            case .schemeStart:
                if let ch = c, ch.ascii.isLetter {
                    buffer.append(Character(UnicodeScalar(ch)).lowercased())
                    state = .scheme
                } else if context.base != nil {
                    state = .noScheme
                    pointer -= 1
                } else {
                    throw .invalidScheme(String(decoding: trimmed, as: UTF8.self))
                }

            case .scheme:
                if let ch = c,
                    ch.ascii.isAlphanumeric || ch == UInt8.ascii.plus || ch == UInt8.ascii.hyphen
                        || ch == UInt8.ascii.period
                {
                    buffer.append(Character(UnicodeScalar(ch)).lowercased())
                } else if c == UInt8.ascii.colon {
                    do throws(Scheme.Error) {
                        url.scheme = try Scheme(buffer)
                    } catch {
                        throw .invalidScheme(buffer)
                    }
                    buffer = ""

                    if Scheme.isSpecial(url.scheme!) {
                        state = .specialAuthoritySlashes
                    } else if trimmed.indices.contains(pointer + 1)
                        && trimmed[pointer + 1] == UInt8.ascii.slash
                    {
                        state = .pathOrAuthority
                        pointer += 1
                    } else {
                        state = .opaquePath
                    }
                } else if context.base != nil {

                    buffer = ""
                    pointer = -1
                    state = .noScheme
                } else {
                    throw .invalidScheme(buffer)
                }

            case .noScheme:
                guard let base = context.base else {
                    throw .invalidStructure("No scheme and no base URL")
                }

                url.scheme = base.scheme

                if c == nil {
                    self = base
                    return
                } else if c == UInt8.ascii.slash {

                    url.host = base.host
                    url.port = base.port
                    state = .pathStart
                } else if c == UInt8.ascii.questionMark {
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    state = .query
                } else if c == UInt8.ascii.numberSign {
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    url.query = base.query
                    state = .fragment
                } else {
                    url.host = base.host
                    url.port = base.port
                    url.path = base.path
                    state = .relativePath
                    pointer -= 1
                }

            case .specialAuthoritySlashes:
                if c == UInt8.ascii.slash && trimmed.indices.contains(pointer + 1)
                    && trimmed[pointer + 1] == UInt8.ascii.slash
                {
                    state = .authority
                    pointer += 1
                } else {
                    throw .invalidStructure("Missing // after special scheme")
                }

            case .pathOrAuthority:
                if c == UInt8.ascii.slash {
                    state = .authority
                } else {
                    state = .path
                    pointer -= 1
                }

            case .authority:
                if c == UInt8.ascii.commercialAt {
                    if atSignSeen {
                        buffer = "%40" + buffer
                    }
                    atSignSeen = true

                    if let colonIndex = buffer.firstIndex(of: ":") {
                        url.username = WHATWG_URL.PercentEncoding.encode(
                            String(buffer[..<colonIndex]),
                            using: .userinfo
                        )
                        url.password = WHATWG_URL.PercentEncoding.encode(
                            String(buffer[buffer.index(after: colonIndex)...]),
                            using: .userinfo
                        )
                    } else {
                        url.username = WHATWG_URL.PercentEncoding.encode(buffer, using: .userinfo)
                    }
                    buffer = ""
                } else if c == nil || c == UInt8.ascii.slash || c == UInt8.ascii.questionMark
                    || c == UInt8.ascii.numberSign
                {
                    pointer -= buffer.count + 1
                    buffer = ""
                    state = .host
                } else {
                    buffer.append(Character(UnicodeScalar(c!)))
                }

            case .host:

                var insideBrackets = false
                while pointer < trimmed.count {
                    let ch = trimmed[pointer]
                    if ch == UInt8.ascii.leftSquareBracket {
                        insideBrackets = true
                    } else if ch == UInt8.ascii.rightSquareBracket {
                        insideBrackets = false
                    }

                    if !insideBrackets
                        && (ch == UInt8.ascii.colon || ch == UInt8.ascii.slash
                            || ch == UInt8.ascii.questionMark || ch == UInt8.ascii.numberSign)
                    {
                        break
                    }
                    buffer.append(Character(UnicodeScalar(ch)))
                    pointer += 1
                }

                let hostContext: Host.Context =
                    Scheme.isSpecial(url.scheme!) ? .special : .nonSpecial
                do throws(Host.Error) {
                    url.host = try Host(ascii: [Byte](buffer.utf8), in: hostContext)
                } catch {
                    throw .invalidHost(error)
                }
                buffer = ""

                if pointer < trimmed.count && trimmed[pointer] == UInt8.ascii.colon {
                    state = .port
                } else {
                    state = .pathStart
                    pointer -= 1
                }

            case .port:
                if let ch = c, ch.ascii.isDigit {
                    buffer.append(Character(UnicodeScalar(ch)))
                } else {
                    if !buffer.isEmpty {
                        guard let port = UInt16(buffer) else {
                            throw .invalidPort(buffer)
                        }

                        let defaultPort = Scheme.defaultPort(for: url.scheme!)
                        if port != defaultPort {
                            url.port = port
                        }
                        buffer = ""
                    }
                    state = .pathStart
                    pointer -= 1
                }

            case .pathStart:
                state = .path
                if c != UInt8.ascii.slash {
                    pointer -= 1
                }

            case .path:
                if c == nil || c == UInt8.ascii.slash || c == UInt8.ascii.questionMark
                    || c == UInt8.ascii.numberSign
                {
                    if !buffer.isEmpty {
                        let decoded = WHATWG_URL.PercentEncoding.decode(buffer)

                        if decoded == ".." {
                            url.popPathSegment()
                        } else if decoded != "." {
                            url.pushPathSegment(decoded)
                        }
                        buffer = ""
                    }

                    if c == UInt8.ascii.slash {

                    } else if c == UInt8.ascii.questionMark {
                        state = .query
                    } else if c == UInt8.ascii.numberSign {
                        state = .fragment
                    } else {

                        break parsing
                    }
                } else {
                    buffer.append(Character(UnicodeScalar(c!)))
                }

            case .relativePath:
                state = .path
                if c != UInt8.ascii.slash {
                    if case .list(var segments) = url.path {
                        if !segments.isEmpty {
                            segments.removeLast()
                        }
                        url.path = .list(segments)
                    }
                    pointer -= 1
                }

            case .opaquePath:
                while pointer < trimmed.count {
                    let ch = trimmed[pointer]
                    if ch == UInt8.ascii.questionMark || ch == UInt8.ascii.numberSign {
                        break
                    }
                    buffer.append(Character(UnicodeScalar(ch)))
                    pointer += 1
                }

                url.path = .opaque(buffer)
                buffer = ""

                if pointer < trimmed.count {
                    let ch = trimmed[pointer]
                    if ch == UInt8.ascii.questionMark {
                        state = .query
                    } else if ch == UInt8.ascii.numberSign {
                        state = .fragment
                    }
                } else {

                    break parsing
                }

            case .query:
                while pointer < trimmed.count {
                    let ch = trimmed[pointer]
                    if ch == UInt8.ascii.numberSign {
                        break
                    }
                    buffer.append(Character(UnicodeScalar(ch)))
                    pointer += 1
                }

                url.query = WHATWG_URL.PercentEncoding.encode(buffer, using: .query)
                buffer = ""

                if pointer < trimmed.count && trimmed[pointer] == UInt8.ascii.numberSign {
                    state = .fragment

                } else {

                    break parsing
                }

            case .fragment:
                while pointer < trimmed.count {
                    buffer.append(Character(UnicodeScalar(trimmed[pointer])))
                    pointer += 1
                }

                url.fragment = WHATWG_URL.PercentEncoding.encode(buffer, using: .fragment)
                buffer = ""

                break parsing
            }

            pointer += 1
        }

        self = try url.build()
    }
}

extension WHATWG_URL.URL {

    public init(_ string: some StringProtocol, base: WHATWG_URL.URL? = nil) throws(Error) {
        let bytes = [Byte](string.utf8)
        try self.init(ascii: bytes, in: ParsingContext(base: base))
    }

    public init?(parsing string: some StringProtocol, base: WHATWG_URL.URL? = nil) {
        do throws(Error) {
            try self.init(string, base: base)
        } catch {
            return nil
        }
    }
}

extension WHATWG_URL.URL: CustomStringConvertible {

    public var description: String {
        String(decoding: serialized, as: UTF8.self)
    }
}
