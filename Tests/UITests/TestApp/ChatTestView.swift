//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SwiftUI


struct ChatTestView: View {
    @State private var chat: Chat = [
//        ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message!"),
//        ChatEntity(role: .assistantToolCall, text: "Tool Call?"),
//        ChatEntity(role: .assistantToolResponse, text: "Tool Response?"),
        ChatEntity(role: .assistant, text: "**Assistant** Message!"),
        ChatEntity(role: .user, text: "Can you tell me a short story?"),
        .shortStoryResponse,
        ChatEntity(role: .user, text: "Write me a `fib` function, in Rust"),
        .fibResponse,
        ChatEntity(role: .user, text: "Give me an overview of the weather around the world"),
        .weatherResponse
    ]
    @State private var muted = true
    
    var body: some View {
        ChatView(
            $chat,
            exportFormat: .pdf,
            messagePendingAnimation: .automatic
        )
        .speak(chat, muted: muted)
        .speechToolbarButton(muted: $muted)
        .navigationTitle("SpeziChat")
        .chatViewInsets(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
        .onChange(of: chat) { _, newValue in
            guard let message = newValue.last, message.role == .user else {
                return
            }
            Task {
                try await generateAssistantMessage(for: message)
            }
        }
    }
    
    private func generateAssistantMessage(for message: ChatEntity) async throws {
        guard message.role == .user, let message = message.content.text else {
            return
        }
        try await Task.sleep(for: .seconds(3))
        if message.localizedCaseInsensitiveContains("call") {
            chat.append(.init(role: .assistantToolCall, text: "call_test_func({ test: true })"))
            try await Task.sleep(for: .seconds(1))
            chat.append(.init(role: .assistantToolResponse, text: "{ some: response }"))
            try await Task.sleep(for: .seconds(1))
            chat.append(.init(role: .assistant, text: "**Assistant** Message Response!"))
        } else if message.localizedCaseInsensitiveContains("weather") {
            chat.append(.weatherResponse)
        } else if message.localizedCaseInsensitiveContains("fib") {
            chat.append(.fibResponse)
        } else if message.localizedCaseInsensitiveContains("image") {
            chat.append(.imageResponse)
        } else {
            chat.append(.init(role: .assistant, text: "**Assistant** Message Response!"))
        }
    }
}


extension ChatEntity {
    fileprivate static let shortStoryResponse = Self(role: .assistant, text: """
        **The Last Cartographer**

        The old woman spread her final map across the table. Every mountain, every river, every forgotten trail — drawn from memory after forty years of walking.

        "This one's wrong," her apprentice said, pointing to a valley that didn't exist on any satellite image.

        "It's not wrong. It's gone." She folded the map carefully. "That's why we draw them."

        The apprentice looked at the blank parchment waiting for him and understood: maps weren't just about what *is*. They were about what someone, someday, might need to find again.
        """
    )
    
    fileprivate static let fibResponse = Self(role: .assistant, text: """
        ```rust
        fn fib(n: u64) -> u64 {
            match n {
                0 | 1 => n,
                _ => fib(n - 1) + fib(n - 2)
            }
        }
        ```
        """
    )
    
    fileprivate static let weatherResponse = Self(role: .assistant, text: """
        Here's the current weather snapshot:
        
        | City | Temp | Condition |
        |------|------|-----------|
        | 🇩🇪 Munich | 41°F / 5°C | ❄️ Snow |
        | 🇦🇹 Vienna | 42°F / 5°C | ☁️ Cloudy |
        | 🇺🇸 San Francisco | 44°F / 7°C | ☁️ Cloudy |
        | 🇬🇧 London | 55°F / 13°C | ☁️ Cloudy |
        | 🇺🇸 New York City | 35°F / 2°C | ☀️ Sunny |
        | 🇳🇴 Svalbard | 0°F / -18°C | 🌤️ Partly Sunny |
        | 🇿🇦 Cape Town | 70°F / 21°C | 🌤️ Partly Sunny |
        | 🇯🇵 Tokyo | — | ⚠️ Data unavailable |
        | 🇨🇦 Toronto | 33°F / 1°C | ☁️ Cloudy |
        | 🇫🇷 Paris | 56°F / 13°C | ☁️ Cloudy |
        
        Tokyo's weather data returned an error — you may want to check a weather service directly for that one.
        """
    )
    
    fileprivate static let imageResponse: Self = {
        guard let url = Bundle.main.url(forResource: "PM5544", withExtension: "png"),
              let image = UIImage(contentsOfFile: url.path) else {
            return Self(role: .assistant, text: "Unable to find image")
        }
        return Self(role: .assistant, image: image)
    }()
}


#if DEBUG
#Preview {
    ChatTestView()
}
#endif
