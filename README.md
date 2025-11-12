# swift-whatwg-url-encoding

WHATWG URL Standard implementation for `application/x-www-form-urlencoded` encoding in Swift.

## Overview

This package implements the [WHATWG URL Living Standard](https://url.spec.whatwg.org/#application/x-www-form-urlencoded) specification for `application/x-www-form-urlencoded` encoding and decoding.

The WHATWG URL Standard defines the precise character set and encoding rules for URL form encoding, which differs from Foundation's URL encoding in key ways:

- **Space encoding**: WHATWG uses `+`, Foundation uses `%20`
- **Character set**: WHATWG only leaves alphanumeric + `*-._` unencoded
- **Specification compliance**: Exact implementation of the WHATWG algorithm

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-whatwg-url-encoding", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "WHATWG URL Encoding", package: "swift-whatwg-url-encoding")
    ]
)
```

## Usage

### Serialize to application/x-www-form-urlencoded

```swift
import WHATWG_URL_Encoding

let encoded = WHATWG_URL_Encoding.serialize([
    ("name", "John Doe"),
    ("email", "john@example.com")
])
// Result: "name=John+Doe&email=john%40example.com"
```

### Parse application/x-www-form-urlencoded

```swift
let pairs = WHATWG_URL_Encoding.parse("name=John+Doe&email=john%40example.com")
// Result: [("name", "John Doe"), ("email", "john@example.com")]
```

### Percent Encoding

```swift
let encoded = WHATWG_URL_Encoding.percentEncode("Hello World!", spaceAsPlus: true)
// Result: "Hello+World%21"
```

### Percent Decoding

```swift
let decoded = WHATWG_URL_Encoding.percentDecode("Hello+World%21", plusAsSpace: true)
// Result: "Hello World!"
```

## WHATWG Character Set

According to the WHATWG URL Standard, only the following characters are left unencoded:

- ASCII alphanumeric (`a-z`, `A-Z`, `0-9`)
- Asterisk (`*`)
- Hyphen (`-`)
- Period (`.`)
- Underscore (`_`)

All other characters are percent-encoded. Space (0x20) is encoded as `+` when `spaceAsPlus` is `true`.

## Difference from Foundation

Foundation's `URLComponents` and related APIs use a different encoding scheme:

```swift
// WHATWG (this package)
"Hello World!" → "Hello+World%21"

// Foundation
"Hello World!" → "Hello%20World!"  // Different space encoding
```

Additionally, Foundation's URL encoding is more permissive with special characters, while WHATWG strictly limits unencoded characters to the set above.

## Reference

- [WHATWG URL Living Standard - application/x-www-form-urlencoded](https://url.spec.whatwg.org/#application/x-www-form-urlencoded)

## Requirements

- Swift 6.0+
- macOS 14.0+, iOS 17.0+, tvOS 17.0+, watchOS 10.0+

## License

MIT
