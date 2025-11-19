// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-whatwg-url-encoding",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "WHATWG URL Encoding",
            targets: ["WHATWG URL Encoding"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WHATWG URL Encoding",
            dependencies: []
        ),
        .testTarget(
            name: "WHATWG URL Encoding".tests,
            dependencies: ["WHATWG URL Encoding"]
        )
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
