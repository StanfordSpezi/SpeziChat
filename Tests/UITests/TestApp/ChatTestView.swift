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
        ChatEntity(role: .hidden(type: .unknown), content: "Hidden Message!"),
        ChatEntity(role: .assistant, content: "**Assistant** Message!")
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
            .padding(.top, 16)
            .onChange(of: chat) { _, newValue in
                guard let message = newValue.last, message.role == .user else {
                    return
                }
                Task {
                    try await generateAssistantMessage(for: message)
                }
            }
    }
    
    private func generateAssistantMessage(for userMessage: ChatEntity) async throws {
        // Append a new assistant message to the chat after sleeping for 5 seconds.
        try await Task.sleep(for: .seconds(3))
        if userMessage.content == "Call some function" {
            chat.append(.init(role: .assistantToolCall, content: "call_test_func({ test: true })"))
            try await Task.sleep(for: .seconds(1))
            chat.append(.init(role: .assistantToolResponse, content: "{ some: response }"))
            try await Task.sleep(for: .seconds(1))
        } else if userMessage.content.localizedCaseInsensitiveContains("weather") {
            chat.append(.init(role: .assistant, content: """
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
                """))
        } else {
            chat.append(.init(role: .assistant, content: "**Assistant** Message Response!"))
        }
    }
}


#if DEBUG
#Preview {
    ChatTestView()
}
#endif
