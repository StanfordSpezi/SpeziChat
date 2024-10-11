// swift-tools-version:5.9

//
// This source file is part of the Stanford Spezi open source project
// 
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

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
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation", from: "2.0.0-beta.3"),
        .package(url: "https://github.com/StanfordSpezi/SpeziSpeech", from: "1.0.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.3.1")
    ],
    targets: [
        .target(
            name: "SpeziChat",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziSpeechRecognizer", package: "SpeziSpeech"),
                .product(name: "SpeziSpeechSynthesizer", package: "SpeziSpeech"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ]
        ),
        .testTarget(
            name: "SpeziChatTests",
            dependencies: [
                .target(name: "SpeziChat")
            ]
        )
    ]
)
