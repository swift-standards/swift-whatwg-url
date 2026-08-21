public import ASCII_Serializer_Primitives

extension WHATWG_URL.URL {

    public enum Path: Hashable, Sendable {

        case opaque(String)

        case list([String])
    }
}

extension WHATWG_URL.URL.Path: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ path: WHATWG_URL.URL.Path,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        switch path {
        case .opaque(let segment):
            for byte in segment.utf8 { buffer.append(ASCII.Code(byte)) }

        case .list(let segments):
            guard !segments.isEmpty else { return }
            for segment in segments {
                buffer.append(ASCII.Code.solidus)
                for byte in segment.utf8 { buffer.append(ASCII.Code(byte)) }
            }
        }
    }
}

extension WHATWG_URL.URL.Path {

    public init<Bytes: Swift.Collection>(
        ascii bytes: Bytes,
        in context: WHATWG_URL.URL.Path.Context
    ) throws(Error) where Bytes.Element == Byte {
        let input = String(decoding: bytes, as: UTF8.self)

        if context.kind == .opaque {

            let decoded = WHATWG_URL.PercentEncoding.decode(input)
            self = .opaque(decoded)
        } else {

            var segments: [String] = []

            for segment in input.split(separator: "/", omittingEmptySubsequences: false) {
                let decoded = WHATWG_URL.PercentEncoding.decode(String(segment))

                if decoded == "." {

                    continue
                } else if decoded == ".." {

                    if !segments.isEmpty {
                        segments.removeLast()
                    }
                } else if !decoded.isEmpty || segments.isEmpty {
                    segments.append(decoded)
                }
            }

            self = .list(segments)
        }
    }
}

extension WHATWG_URL.URL.Path: CustomStringConvertible {

    public var description: String { String(decoding: serialized, as: UTF8.self) }
}

extension WHATWG_URL.URL.Path {

    public static var emptyList: Self {
        .list([])
    }

    public static var emptyOpaque: Self {
        .opaque("")
    }

    public var isEmpty: Bool {
        switch self {
        case .opaque(let segment):
            return segment.isEmpty

        case .list(let segments):
            return segments.isEmpty
        }
    }

    @discardableResult
    public mutating func shorten(scheme: WHATWG_URL.URL.Scheme) -> Bool {
        switch self {
        case .opaque:

            return false

        case .list(var segments):

            guard !segments.isEmpty else { return false }

            if scheme.value == "file" && segments.count == 1 {
                if let first = segments.first, isWindowsDriveLetter(first) {
                    return false
                }
            }

            segments.removeLast()
            self = .list(segments)
            return true
        }
    }

    public mutating func append(_ segment: String) {
        switch self {
        case .opaque:

            break

        case .list(var segments):
            segments.append(segment)
            self = .list(segments)
        }
    }

    private func isWindowsDriveLetter(_ string: String) -> Bool {
        guard string.count == 2 else { return false }
        let chars = Array(string)
        guard chars[0].isLetter else { return false }
        return chars[1] == ":" || chars[1] == "|"
    }
}
