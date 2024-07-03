//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFAudio
import SpeziChat
import SpeziSpeechSynthesizer
import SwiftUI


struct ChatTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .hidden(type: .unknown), content: "Hidden Message!"),
        ChatEntity(role: .assistant, content: "**Assistant** Message!")
    ]
    @State private var muted = true
    
    let speechSynthesizer = SpeechSynthesizer()
    
    var body: some View {
        ChatView(
            $chat,
            exportFormat: .pdf,
            messagePendingAnimation: .automatic
        )
            .speak(chat, muted: muted, voice: speechSynthesizer.voices[5])
            .speechToolbarButton(muted: $muted)
            .navigationTitle("SpeziChat")
            .padding(.top, 16)
            .onChange(of: chat) { _, newValue in
                // Append a new assistant message to the chat after sleeping for 5 seconds.
                if newValue.last?.role == .user {
                    Task {
                        try await Task.sleep(for: .seconds(5))
                        
                        await MainActor.run {
                            chat.append(.init(role: .assistant, content: "**Assistant** Message Response!"))
                        }
                    }
                }
            }
    }
}


#if DEBUG
#Preview {
    ChatTestView()
}
#endif
