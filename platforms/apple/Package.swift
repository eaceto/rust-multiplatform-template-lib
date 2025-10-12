// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Template",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Template",
            targets: ["Template"]
        )
    ],
    targets: [
        .target(
            name: "Template",
            dependencies: ["TemplateFFI"],
            path: "Sources/Template"
        ),
        .binaryTarget(
            name: "TemplateFFI",
            path: "xcframework/librust_multiplatform_template_lib.xcframework"
        ),
        .testTarget(
            name: "TemplateTests",
            dependencies: ["Template"],
            path: "Tests/TemplateTests"
        )
    ]
)
