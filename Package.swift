// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-whatwg-url-encoding",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
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
            name: "WHATWG URL Encoding Tests",
            dependencies: ["WHATWG URL Encoding"]
        )
    ]
)

for target in package.targets {
    target.swiftSettings?.append(
        contentsOf: [
            .enableUpcomingFeature("MemberImportVisibility")
        ]
    )
}
