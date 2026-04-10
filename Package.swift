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
            url: "https://github.com/salesforce/AgentforceMobileSDK-iOS/releases/download/15.5.1/AgentforceMobileSDK-260-3.xcframework.zip",
            checksum: "52653617b68d5e535a05314087c3c36a0177fa7d3764b8b7b0cb66c7269199fd"
        ),
        .target(
            name: "AgentforceSDKTarget",
            dependencies: [
                "AgentforceSDK",
                .product(name: "AgentforceService", package: "AgentforceMobileService-iOS"),
                .product(name: "SalesforceNavigation", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceLogging", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceNetwork", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "SalesforceUser", package: "SalesforceMobileInterfaces-iOS"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ],
            path: "Sources/AgentforceSDKTarget"
        )
    ],
    swiftLanguageVersions: [.v5]
)
