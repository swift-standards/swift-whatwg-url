// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let whatwgURL: Self = "WHATWG URL"
    static let whatwgFormURLEncoded: Self = "WHATWG Form URL Encoded"
}

extension Target.Dependency {
    static var whatwgURL: Self { .target(name: .whatwgURL) }
    static var whatwgFormURLEncoded: Self { .target(name: .whatwgFormURLEncoded) }
}

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
        .package(url: "https://github.com/swift-ietf/swift-rfc-3987.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-791.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main"),
        .package(
            url: "https://github.com/swift-standards/swift-domain-standard.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte-parser.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "WHATWG URL",
            dependencies: [
                .whatwgFormURLEncoded,
                .product(name: "RFC 3987", package: "swift-rfc-3987"),
                .product(name: "RFC 791", package: "swift-rfc-791"),
                .product(name: "RFC 5952", package: "swift-rfc-5952"),
                .product(name: "Domain Standard", package: "swift-domain-standard"),
                .product(
                    name: "ASCII Serializer",
                    package: "swift-ascii-serializer"
                ),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Parser", package: "swift-parser"),
                .product(
                    name: "Parseable ASCII",
                    package: "swift-ascii-parser"
                ),
                .product(name: "Byte Parser", package: "swift-byte-parser"),
            ]
        ),

        .target(
            name: "WHATWG Form URL Encoded",
            dependencies: [
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(
                    name: "ASCII Serializer",
                    package: "swift-ascii-serializer"
                ),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Binary", package: "swift-binary"),
                .product(
                    name: "Parseable ASCII",
                    package: "swift-ascii-parser"
                ),
            ]
        ),

        .testTarget(
            name: "WHATWG Form URL Encoded Tests",
            dependencies: [
                "WHATWG URL"
            ]
        ),
        .testTarget(
            name: "WHATWG URL Tests",
            dependencies: [
                "WHATWG URL"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

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
