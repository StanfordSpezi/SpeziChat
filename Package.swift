// swift-tools-version:6.0

//
// This source file is part of the Stanford Spezi open source project
// 
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


let package = Package(
    name: "SpeziChat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SpeziChat", targets: ["SpeziChat"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation", from: "2.0.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziSpeech", from: "1.1.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.8.0")
    ],
    targets: [
        .target(
            name: "SpeziChat",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziSpeechRecognizer", package: "SpeziSpeech"),
                .product(name: "SpeziSpeechSynthesizer", package: "SpeziSpeech"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziChatTests",
            dependencies: [
                .target(name: "SpeziChat")
            ]
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.55.1")]
    } else {
        []
    }
}
