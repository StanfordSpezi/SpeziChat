//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import SpeziSpeechSynthesizer


struct ChatViewSpeechButtonModifier: ViewModifier {
    let enabled: Bool
    @Binding var muted: Bool
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var speechSynthesizer = SpeechSynthesizer()
    
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if enabled {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            muted.toggle()
                        }) {
                            if !muted {
                                Image(systemName: "speaker")
                                    .accessibilityLabel(Text("Text to speech is enabled, press to disable text to speech.", bundle: .module))
                            } else {
                                Image(systemName: "speaker.slash")
                                    .accessibilityLabel(Text("Text to speech is disabled, press to enable text to speech.", bundle: .module))
                            }
                        }
                    }
                }
            }
    }
}


extension View {
    public func speechToolbarButton(
        enabled: Bool = true,
        muted: Binding<Bool>
    ) -> some View {
        modifier(
            ChatViewSpeechButtonModifier(
                enabled: enabled,
                muted: muted
            )
        )
    }
}


#if DEBUG
#Preview {
    @State var chat: Chat = .init(
        [
            ChatEntity(role: .system, content: "System Message!"),
            ChatEntity(role: .system, content: "System Message (hidden)!"),
            ChatEntity(role: .user, content: "User Message!"),
            ChatEntity(role: .assistant, content: "Assistant Message!"),
            ChatEntity(role: .function(name: "test_function"), content: "Function Message!")
        ]
    )
    @State var muted = true
    
    
    return NavigationStack {
        ChatView(
            $chat,
            exportFormat: .pdf
        )
            .speakChat(chat, muted: muted)
            .speechToolbarButton(muted: $muted)
    }
}
#endif
