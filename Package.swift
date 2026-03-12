// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AgentforceMobileSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AgentforceSDK",
            targets: ["AgentforceSDKTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/forcedotcom/AgentforceMobileService-iOS.git", from: "4.0.0"),
        .package(url: "https://github.com/forcedotcom/SalesforceMobileInterfaces-iOS.git", from: "1.0.0"),
        .package(url: "https://github.com/salesforce-misc/swift-markdown-ui.git", from: "2.4.0"),
    ],
    targets: [
        .binaryTarget(
            name: "AgentforceSDK",
            url: "https://github.com/salesforce/AgentforceMobileSDK-iOS/releases/download/15.0.7/AgentforceMobileSDK-260-1.xcframework.zip",
            checksum: "f034aef2e233cf06ff0cb6e9896e797e1d783d53ad11ca503a575fbf138d0275"
        ),
        // Shim: the binary imports "swift_markdown_ui" but SPM builds it as "MarkdownUI"
        .target(
            name: "swift_markdown_ui",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ],
            path: "Sources/swift_markdown_ui"
        ),
        .target(
            name: "AgentforceSDKTarget",
            dependencies: [
                "AgentforceSDK",
                "swift_markdown_ui",
                .product(name: "AgentforceService", package: "AgentforceMobileService-iOS"),
                .product(name: "SalesforceNavigation", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceLogging", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceNetwork", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceUser", package: "SalesforceMobileInterfaces-iOS"),
            ],
            path: "Sources/AgentforceSDKTarget"
        )
    ],
    swiftLanguageVersions: [.v5]
)
