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

let enableSwiftLintPlugin = false


let package = Package(
    name: "SpeziChat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .visionOS(.v2),
        .macOS(.v15)
    ],
    products: [
        .library(name: "SpeziChat", targets: ["SpeziChat"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.0.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziSpeech.git", from: "1.1.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", branch: "lukas/FilePicker"),
        .package(url: "https://github.com/gonzalezreal/textual.git", from: "0.3.1")
    ] + swiftLintPackage,
    targets: [
        .target(
            name: "SpeziChat",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziSpeechRecognizer", package: "SpeziSpeech"),
                .product(name: "SpeziSpeechSynthesizer", package: "SpeziSpeech"),
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "Textual", package: "textual")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .testTarget(
            name: "SpeziChatTests",
            dependencies: [
                .target(name: "SpeziChat")
            ]
        )
    ]
)


// MARK: SwiftLint support

var swiftLintPlugin: [Target.PluginUsage] {
    if enableSwiftLintPlugin {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    } else {
        []
    }
}

var swiftLintPackage: [PackageDescription.Package.Dependency] {
    if enableSwiftLintPlugin {
        [.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.63.2")]
    } else {
        []
    }
}
