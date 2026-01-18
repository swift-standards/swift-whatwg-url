// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let whatwgURL: Self = "WHATWG URL"
    static let whatwgFormURLEncoded: Self = "WHATWG Form URL Encoded"
}

extension Target.Dependency {
    static var whatwgURL: Self { .target(name: .whatwgURL) }
    static var whatwgFormURLEncoded: Self { .target(name: .whatwgFormURLEncoded) }
    static var rfc3987: Self { .product(name: "RFC 3987", package: "swift-rfc-3987") }
    static var rfc791: Self { .product(name: "RFC 791", package: "swift-rfc-791") }
    static var rfc5952: Self { .product(name: "RFC 5952", package: "swift-rfc-5952") }
    static var domainStandard: Self { .product(name: "Domain Standard", package: "swift-domain-standard") }
    static var rfc4648: Self { .product(name: "RFC 4648", package: "swift-rfc-4648") }
    static var incits41986: Self { .product(name: "ASCII", package: "swift-ascii") }
    static var binary: Self { .product(name: "Binary Primitives", package: "swift-binary-primitives") }
}

let package = Package(
    name: "swift-whatwg-url",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        // Main URL standard
        .library(
            name: "WHATWG URL",
            targets: ["WHATWG URL"]
        ),
        // Form URL encoding (application/x-www-form-urlencoded)
        .library(
            name: "WHATWG Form URL Encoded",
            targets: ["WHATWG Form URL Encoded"]
        )
    ],
    dependencies: [
        .package(path: "../swift-rfc-3987"),
        .package(path: "../swift-rfc-791"),
        .package(path: "../swift-rfc-5952"),
        .package(path: "../swift-domain-standard"),
        .package(path: "../swift-rfc-4648"),
        .package(path: "../../swift-foundations/swift-ascii"),
        .package(path: "../../swift-primitives/swift-binary-primitives")
    ],
    targets: [
        // Core URL implementation
        .target(
            name: "WHATWG URL",
            dependencies: [
                .whatwgFormURLEncoded,
                .rfc3987,
                .rfc791,
                .rfc5952,
                .domainStandard,
                .incits41986,
                .binary
            ]
        ),

        // application/x-www-form-urlencoded (Section 5)
        .target(
            name: "WHATWG Form URL Encoded",
            dependencies: [
                .rfc4648,
                .incits41986,
                .binary
            ]
        ),

        // Tests
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
