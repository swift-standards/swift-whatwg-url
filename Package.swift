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
    static var domainStandard: Self { .product(name: "Domain Standard", package: "swift-domain-standard") }
}

let package = Package(
    name: "swift-whatwg-url",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
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
        .package(path: "../swift-domain-standard"),
    ],
    targets: [
        // Core URL implementation
        .target(
            name: .whatwgURL,
            dependencies: [
                .whatwgFormURLEncoded,
                .rfc3987,
                .domainStandard,
            ]
        ),

        // application/x-www-form-urlencoded (Section 5)
        .target(
            name: .whatwgFormURLEncoded,
            dependencies: []
        ),

        // Tests
        .testTarget(
            name: .whatwgURL.tests,
            dependencies: [.whatwgURL]
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
