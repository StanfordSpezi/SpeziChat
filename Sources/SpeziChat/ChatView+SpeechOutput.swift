//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziSpeechSynthesizer
import SwiftUI


/// The underlying `ViewModifier` of ``ChatView/speakChat(_:muted:)``.
struct ChatViewSpeechModifier: ViewModifier {
    let chat: Chat
    let muted: Bool
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var speechSynthesizer = SpeechSynthesizer()
    
    
    func body(content: Content) -> some View {
        content
            // Output speech when new complete assistant message is the last message
            // Cancel speech output as soon as new message arrives with user role
            .onChange(of: chat, initial: true) { _, _ in
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
    /// Provides text-to-speech capabilities to the ``ChatView``.
    ///
    /// Attaching the modifier to a ``ChatView`` will enable the automatic output of the latest added ``ChatEntity/Role-swift.enum/assistant`` chat message that is ``ChatEntity/complete`` within the passed ``Chat``.
    /// The text-to-speech capability can be muted via a `Bool` flag in the ``speakChat(_:muted:)`` modifier.
    ///
    /// It is important to note that only the latest ``ChatEntity/Role-swift.enum/assistant`` and ``ChatEntity/complete`` ``Chat`` messages will be synthezised to natural language speech.
    /// The speech output is immediately stopped as soon as a ``ChatEntity/complete`` ``ChatEntity/Role-swift.enum/user`` message is added to the ``Chat``,
    /// the passed in `muted` `Binding` turns to `true`, or the `View` is inactive or in the background.
    ///
    /// ### Usage
    ///
    /// The code snipped below demonstrates a minimal example of text-to-speech capabilities. At first, the speech output is muted, only after ten seconds speech output of newly incoming ``Chat`` messages will be synthezised.
    ///
    /// ```swift
    /// struct ChatTestView: View {
    ///     @State private var chat: Chat = [
    ///         ChatEntity(role: .assistant, content: "**Assistant** Message!")
    ///     ]
    ///     @State private var muted = true
    ///
    ///
    ///     var body: some View {
    ///         ChatView($chat)
    ///             .speakChat(chat, muted: muted)
    ///             .task {
    ///                 try? await Task.sleep(for: .seconds(10))
    ///                 muted = false
    ///
    ///                 // Add new completed `assistant` content to the `Chat` that is outputted via speech.
    ///                 // ...
    ///             }
    ///     }
    /// }
    /// ```
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
        ChatView($chat)
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
        ChatView($chat)
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
        ChatView($chat)
            .speakChat(chat, muted: muted)
    }
}
#endif
