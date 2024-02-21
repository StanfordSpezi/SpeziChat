//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import SpeziSpeechSynthesizer


struct ChatViewSpeechModifier: ViewModifier {
    let chat: Chat
    let muted: Bool
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var speechSynthesizer = SpeechSynthesizer()
    
    
    func body(content: Content) -> some View {
        content
            // Output speech when new complete assistant message is the last message
            // Cancel speech output as soon as new message arrives with user role
            .onChange(of: chat, initial: true) { _, newValue in
                guard !muted,
                      let lastChatEntity = chat.last,
                      lastChatEntity.complete else {
                    return
                }
                
                if lastChatEntity.role == .assistant {
                    speechSynthesizer.speak(lastChatEntity.content)
                } else if lastChatEntity.role == .user {
                    speechSynthesizer.stop()
                }
            }
            // Cancel speech output when muted button is tapped in the toolbar
            .onChange(of: muted) { _, newValue in
                if newValue {
                    speechSynthesizer.stop()
                }
            }
            // Cancel speech output when view disappears
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .background, .inactive: speechSynthesizer.stop()
                default: break
                }
            }
    }
}


extension ChatView {
    public func speakChat(
        _ chat: Chat,
        muted: Bool
    ) -> some View {
        modifier(
            ChatViewSpeechModifier(
                chat: chat,
                muted: muted
            )
        )
    }
}


#if DEBUG
#Preview("ChatView") {
    @State var chat: Chat = .init(
        [
            ChatEntity(role: .system, content: "System Message!"),
            ChatEntity(role: .system, content: "System Message (hidden)!"),
            ChatEntity(role: .user, content: "User Message!"),
            ChatEntity(role: .assistant, content: "Assistant Message!"),
            ChatEntity(role: .function(name: "test_function"), content: "Function Message!")
        ]
    )
    
    return NavigationStack {
        ChatView(
            $chat,
            exportFormat: .pdf
        )
    }
}

#Preview("ChatViewSpeechOutput") {
    @State var chat: Chat = .init(
        [
            ChatEntity(role: .assistant, content: "Assistant Message!")
        ]
    )
    @State var muted = false
    
    
    return NavigationStack {
        ChatView(
            $chat,
            exportFormat: .pdf
        )
            .speakChat(chat, muted: muted)
    }
}

#Preview("ChatViewSpeechOutputDisabled") {
    @State var chat: Chat = .init(
        [
            ChatEntity(role: .assistant, content: "Assistant Message!")
        ]
    )
    @State var muted = true
    
    
    return NavigationStack {
        ChatView(
            $chat,
            exportFormat: .pdf
        )
            .speakChat(chat, muted: muted)
    }
}
#endif
