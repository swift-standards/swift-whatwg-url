public import ASCII_Serializer_Primitives
public import Domain_Standard
public import RFC_5952
public import RFC_791

extension WHATWG_URL.URL {

    public enum Host: Hashable, Sendable {

        case domain(Domain_Standard.Domain)

        case ipv4(RFC_791.IPv4.Address)

        case ipv6(RFC_4291.IPv6.Address)

        case opaque(String)

        case empty
    }
}

extension WHATWG_URL.URL.Host: ASCII.Serializable {

    public static func serialize<Buffer>(
        _ host: WHATWG_URL.URL.Host,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        switch host {
        case .domain(let domain):
            for byte in domain.name.utf8 { buffer.append(ASCII.Code(byte)) }

        case .ipv4(let address):
            RFC_791.IPv4.Address.serialize(address, into: &buffer)

        case .ipv6(let address):
            buffer.append(ASCII.Code.leftSquareBracket)
            RFC_4291.IPv6.Address.serialize(address, into: &buffer)
            buffer.append(ASCII.Code.rightSquareBracket)

        case .opaque(let host):
            for byte in host.utf8 { buffer.append(ASCII.Code(byte)) }

        case .empty:
            break
        }
    }
}

extension WHATWG_URL.URL.Host {

    public init<Bytes: Swift.Collection>(
        ascii bytes: Bytes,
        in context: Context
    ) throws(Error) where Bytes.Element == Byte {
        let array = [Byte](bytes)

        guard !array.isEmpty else {
            self = .empty
            return
        }

        if array.first == Byte.ascii.leftSquareBracket {
            guard array.last == Byte.ascii.rightSquareBracket else {
                throw .ipv6BracketMismatch
            }

            let ipv6String = String(decoding: array, as: UTF8.self)

            if let address = RFC_4291.IPv6.Address(whatwgString: ipv6String) {
                self = .ipv6(address)
            } else {
                throw .invalidIPv6Address(ipv6String)
            }
            return
        }

        let hostString = String(decoding: array, as: UTF8.self)

        if context.kind == .special {

            let couldBeIPv4 = hostString.allSatisfy { c in
                c.isNumber || c == "." || c == "x" || c == "X" || (c >= "a" && c <= "f")
                    || (c >= "A" && c <= "F")
            }

            if couldBeIPv4, let address = RFC_791.IPv4.Address(whatwgString: hostString) {
                self = .ipv4(address)
                return
            }

            do throws(Domain_Standard.Domain.Error) {
                let domain = try Domain_Standard.Domain(hostString)
                self = .domain(domain)
            } catch {
                throw .invalidDomain(hostString)
            }
        } else {

            self = .opaque(hostString)
        }
    }
}

extension WHATWG_URL.URL.Host: CustomStringConvertible {

    public var description: String { String(decoding: serialized, as: UTF8.self) }
}
