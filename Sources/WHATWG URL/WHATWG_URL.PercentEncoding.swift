import ASCII_Primitives
import ASCII_Serializer_Primitives

extension WHATWG_URL {

    enum PercentEncoding {}
}

extension WHATWG_URL.PercentEncoding {

    @inline(always)
    private static func hexDigit(_ nibble: UInt8) -> String {

        let code = ASCII.Hexadecimal.code(nibble & 0x0F, case: .upper)!
        return String(Character(UnicodeScalar(code)))
    }
}

extension WHATWG_URL.PercentEncoding {

    static func decode(_ input: String) -> String {
        var result = ""
        var chars = Array(input)
        var i = 0

        while i < chars.count {
            if chars[i] == "%", i + 2 < chars.count {

                let hex = String(chars[i + 1...i + 2])
                if let byte = UInt8(hex, radix: 16) {

                    var bytes: [UInt8] = [byte]
                    i += 3

                    while i < chars.count && chars[i] == "%", i + 2 < chars.count {
                        let nextHex = String(chars[i + 1...i + 2])
                        if let nextByte = UInt8(nextHex, radix: 16) {
                            bytes.append(nextByte)
                            i += 3
                        } else {
                            break
                        }
                    }

                    let decoded = String(decoding: bytes, as: UTF8.self)

                    if decoded.utf8.elementsEqual(bytes) {
                        result += decoded
                    } else {

                        for byte in bytes {
                            result += "%"
                            result += hexDigit(byte >> 4)
                            result += hexDigit(byte & 0x0F)
                        }
                    }
                    continue
                }
            }

            result.append(chars[i])
            i += 1
        }

        return result
    }
}

extension WHATWG_URL.PercentEncoding {

    static func encode(_ input: String, using set: EncodeSet) -> String {
        var result = ""

        for char in input {
            if set.shouldEncode(char) {

                for byte in String(char).utf8 {
                    result += "%"
                    result += hexDigit(byte >> 4)
                    result += hexDigit(byte & 0x0F)
                }
            } else {
                result.append(char)
            }
        }

        return result
    }
}
