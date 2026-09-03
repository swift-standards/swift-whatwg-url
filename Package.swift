// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-whatwg-url",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [

        .library(
            name: "WHATWG URL",
            targets: ["WHATWG URL"]
        ),

        .library(
            name: "WHATWG Form URL Encoded",
            targets: ["WHATWG Form URL Encoded"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3987.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-791.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main"),
        .package(
            url: "https://github.com/swift-standards/swift-domain-standard.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-binary-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-parser-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-parser-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "WHATWG URL",
            dependencies: [
                .target(name: "WHATWG Form URL Encoded"),
                .product(name: "RFC 3987", package: "swift-rfc-3987"),
                .product(name: "RFC 791", package: "swift-rfc-791"),
                .product(name: "RFC 5952", package: "swift-rfc-5952"),
                .product(name: "Domain Standard", package: "swift-domain-standard"),
                .product(
                    name: "ASCII Serializer Primitives",
                    package: "swift-ascii-serializer-primitives"
                ),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(
                    name: "Parseable ASCII Primitives",
                    package: "swift-ascii-parser-primitives"
                ),
                .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives"),
            ]
        ),

        .target(
            name: "WHATWG Form URL Encoded",
            dependencies: [
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(
                    name: "ASCII Serializer Primitives",
                    package: "swift-ascii-serializer-primitives"
                ),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(
                    name: "Parseable ASCII Primitives",
                    package: "swift-ascii-parser-primitives"
                ),
            ]
        ),

        .testTarget(
            name: "WHATWG Form URL Encoded Tests",
            dependencies: [
                .target(name: "WHATWG URL")
            ]
        ),
        .testTarget(
            name: "WHATWG URL Tests",
            dependencies: [
                .target(name: "WHATWG URL")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
