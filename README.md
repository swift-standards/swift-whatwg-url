# swift-whatwg-url

WHATWG URL Living Standard implementation in Swift.

## Overview

This package implements the [WHATWG URL Living Standard](https://url.spec.whatwg.org/), providing:

- **WHATWG URL**: Full URL parsing, serialization, and manipulation (planned)
- **WHATWG Form URL Encoded**: Section 5 - `application/x-www-form-urlencoded` encoding and decoding

The WHATWG URL Standard defines the precise character set and encoding rules for URL form encoding, which differs from Foundation's URL encoding in key ways:

- **Space encoding**: WHATWG uses `+`, Foundation uses `%20`
- **Character set**: WHATWG only leaves alphanumeric + `*-._` unencoded
- **Specification compliance**: Exact implementation of the WHATWG algorithm

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-whatwg-url", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        // For full URL support (planned)
        .product(name: "WHATWG URL", package: "swift-whatwg-url"),

        // Or just for form URL encoding
        .product(name: "WHATWG Form URL Encoded", package: "swift-whatwg-url")
    ]
)
```

## Usage

### WHATWG Form URL Encoded

#### Serialize to application/x-www-form-urlencoded

```swift
import WHATWG_Form_URL_Encoded

let encoded = WHATWG_Form_URL_Encoded.serialize([
    ("name", "John Doe"),
    ("email", "john@example.com")
])
// Result: "name=John+Doe&email=john%40example.com"
```

#### Parse application/x-www-form-urlencoded

```swift
let pairs = WHATWG_Form_URL_Encoded.parse("name=John+Doe&email=john%40example.com")
// Result: [("name", "John Doe"), ("email", "john@example.com")]
```

#### Percent Encoding

```swift
let encoded = WHATWG_Form_URL_Encoded.percentEncode("Hello World!", spaceAsPlus: true)
// Result: "Hello+World%21"
```

#### Percent Decoding

```swift
let decoded = WHATWG_Form_URL_Encoded.percentDecode("Hello+World%21", plusAsSpace: true)
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

- [WHATWG URL Living Standard](https://url.spec.whatwg.org/)
- [Section 5: application/x-www-form-urlencoded](https://url.spec.whatwg.org/#application/x-www-form-urlencoded)

## Requirements

- Swift 6.2+
- macOS 15.0+, iOS 18.0+, tvOS 18.0+, watchOS 11.0+

## License

Apache 2.0
