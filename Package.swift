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
    static var incits41986: Self { .product(name: "INCITS 4 1986", package: "swift-incits-4-1986") }
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
            name: .whatwgURL,
            targets: [.whatwgURL]
        ),
        // Form URL encoding (application/x-www-form-urlencoded)
        .library(
            name: .whatwgFormURLEncoded,
            targets: [.whatwgFormURLEncoded]
        ),
    ],
    dependencies: [
        .package(path: "../swift-rfc-3987"),
        .package(path: "../swift-rfc-791"),
        .package(path: "../swift-rfc-5952"),
        .package(path: "../swift-domain-standard"),
        .package(path: "../swift-rfc-4648"),
        .package(path: "../swift-incits-4-1986"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../../swift-primitives/swift-test-primitives"),
    ],
    targets: [
        // Core URL implementation
        .target(
            name: .whatwgURL,
            dependencies: [
                .whatwgFormURLEncoded,
                .rfc3987,
                .rfc791,
                .rfc5952,
                .domainStandard,
                .incits41986,
                .binary,
            ]
        ),

        // application/x-www-form-urlencoded (Section 5)
        .target(
            name: .whatwgFormURLEncoded,
            dependencies: [
                .rfc4648,
                .incits41986,
                .binary,
            ]
        ),

        // Tests
        .testTarget(
            name: .whatwgURL.tests,
            dependencies: [
                .whatwgURL,
                .product(name: "Test Primitives", package: "swift-test-primitives")
            ]
        ),
        .testTarget(
            name: .whatwgFormURLEncoded.tests,
            dependencies: [.whatwgFormURLEncoded]
        ),
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
