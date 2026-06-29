// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FormWizardSPM",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "FormWizard",
            targets: ["FormWizard"]
        )
    ],
    targets: [
        .target(
            name: "FormWizard",
            path: "Sources/FormWizard"
        ),
        .testTarget(
            name: "FormWizardTests",
            dependencies: ["FormWizard"],
            path: "Tests/FormWizardTests"
        )
    ]
)
