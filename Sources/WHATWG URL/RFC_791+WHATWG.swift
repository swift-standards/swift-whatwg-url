public import RFC_791

extension RFC_791.IPv4.Address {

    public init?(whatwgString: String) {
        let parts = whatwgString.split(separator: ".")

        guard !parts.isEmpty && parts.count <= 4 else {
            return nil
        }

        var numbers: [UInt32] = []
        for part in parts {
            guard let num = Self.parseWHATWGNumber(String(part)) else {
                return nil
            }
            numbers.append(num)
        }

        guard let address = Self.constructFromWHATWGNumbers(numbers) else {
            return nil
        }

        self = address
    }

    private static func parseWHATWGNumber(_ string: String) -> UInt32? {
        guard !string.isEmpty else { return nil }

        let chars = Array(string)

        if chars.count > 2 && chars[0] == "0" && (chars[1] == "x" || chars[1] == "X") {
            let hex = String(chars[2...])
            return UInt32(hex, radix: 16)
        }

        if chars.count > 1 && chars[0] == "0" {
            let octal = String(chars[1...])
            guard octal.allSatisfy({ $0 >= "0" && $0 <= "7" }) else {
                return nil
            }
            return UInt32(octal, radix: 8)
        }

        return UInt32(string, radix: 10)
    }

    private static func constructFromWHATWGNumbers(_ numbers: [UInt32]) -> Self? {

        for value in numbers.dropLast() {
            guard value < 256 else { return nil }
        }

        var address: UInt32 = 0

        switch numbers.count {
        case 1:
            address = numbers[0]

        case 2:
            guard numbers[1] < (1 << 24) else { return nil }
            address = (numbers[0] << 24) | numbers[1]

        case 3:
            guard numbers[2] < (1 << 16) else { return nil }
            address = (numbers[0] << 24) | (numbers[1] << 16) | numbers[2]

        case 4:
            guard numbers[3] < 256 else { return nil }
            address = (numbers[0] << 24) | (numbers[1] << 16) | (numbers[2] << 8) | numbers[3]

        default:
            return nil
        }

        return Self(rawValue: address)
    }
}
