import ASCII_Primitives
import ASCII_Serializer_Primitives

extension WHATWG_Form_URL_Encoded {

    public enum PercentEncoding {}
}

extension WHATWG_Form_URL_Encoded.PercentEncoding {

    public static func encode(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> String {
        var result = ""

        for byte in string.utf8 {
            switch byte {

            case _ where byte.ascii.isAlphanumeric:
                result.append(Character(UnicodeScalar(byte)))

            case UInt8.ascii.asterisk,
                UInt8.ascii.hyphen,
                UInt8.ascii.period,
                UInt8.ascii.underline:
                result.append(Character(UnicodeScalar(byte)))

            case UInt8.ascii.sp:
                result.append(space == .plus ? "+" : "%20")

            default:

                result.append("%")
                result.append(
                    Character(UnicodeScalar(ASCII.Hexadecimal.code(byte >> 4, case: .upper)!))
                )
                result.append(
                    Character(UnicodeScalar(ASCII.Hexadecimal.code(byte & 0x0F, case: .upper)!))
                )
            }
        }

        return result
    }
}

extension WHATWG_Form_URL_Encoded.PercentEncoding {

    public static func decode(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) throws(Error) -> String {
        var bytes: [UInt8] = []
        var index = string.startIndex

        while index < string.endIndex {
            let char = string[index]

            if char == "+" && space == .plus {
                bytes.append(UInt8.ascii.sp)
                index = string.index(after: index)
            } else if char == "%" {

                let nextIndex = string.index(after: index)
                guard nextIndex < string.endIndex else {
                    throw .unexpectedEndOfInput
                }

                let secondIndex = string.index(after: nextIndex)
                guard secondIndex < string.endIndex else {
                    throw .unexpectedEndOfInput
                }

                let hexString = String(string[nextIndex...secondIndex])
                guard let byte = UInt8(hexString, radix: 16) else {
                    throw .invalidPercentEncoding(
                        position: string.distance(from: string.startIndex, to: index),
                        found: "%" + hexString
                    )
                }

                bytes.append(byte)
                index = string.index(after: secondIndex)
            } else {
                bytes.append(contentsOf: String(char).utf8)
                index = string.index(after: index)
            }
        }

        return String(decoding: bytes, as: UTF8.self)
    }

    public static func decodeOrNil(
        _ string: String,
        space: WHATWG_Form_URL_Encoded.SpaceEncoding = .plus
    ) -> String? {
        do throws(Error) {
            return try decode(string, space: space)
        } catch {
            return nil
        }
    }
}
