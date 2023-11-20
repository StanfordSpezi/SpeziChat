//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Provides a basic reusable chat view which includes a message input field. The input can be either typed out via the iOS keyboard or provided as voice input and transcribed into written text.
///
/// The actual content of the ``ChatView`` is defined by a ``Chat``, which contains an ordered array of ``ChatEntity``s representing the individual messages within the ``ChatView``.
/// The ``Chat`` is passed to the ``ChatView`` as a SwiftUI `Binding`, which enables modification of the ``Chat`` from outside of the view, for example via a SwiftUI `.onChange()` `View` modifier.
///
///
/// ```swift
/// struct ChatTestView: View {
///     @State private var chat: Chat = [
///         ChatEntity(role: .assistant, content: "Assistant Message!")
///     ]
///
///     var body: some View {
///         ChatView($chat)
///             .navigationTitle("SpeziChat")
///     }
/// }
/// ```
public struct ChatView: View {
    @Binding var chat: Chat
    @Binding var disableInput: Bool
    let messagePlaceholder: String?
    
    @State var messageInputHeight: CGFloat = 0
    
    
    public var body: some View {
        ZStack {
            VStack {
                MessagesView($chat, bottomPadding: $messageInputHeight)
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                        }
                    )
            }
            VStack {
                Spacer()
                MessageInputView($chat, messagePlaceholder: messagePlaceholder)
                    .disabled(disableInput)
                    .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
                        messageInputHeight = newValue
                    }
            }
        }
    }
    
    
    /// - Parameters:
    ///   - chat: The chat that should be displayed.
    ///   - disableInput: Flag if the input view should be disabled.
    ///   - messagePlaceholder: Placeholder text that should be added in the input field.
    public init(
        _ chat: Binding<Chat>,
        disableInput: Binding<Bool> = .constant(false),
        messagePlaceholder: String? = nil
    ) {
        self._chat = chat
        self._disableInput = disableInput
        self.messagePlaceholder = messagePlaceholder
    }
}


#Preview {
    ChatView(.constant(
        [
            ChatEntity(role: .system, content: "System Message!"),
            ChatEntity(role: .system, content: "System Message (hidden)!"),
            ChatEntity(role: .user, content: "User Message!"),
            ChatEntity(role: .assistant, content: "Assistant Message!"),
            ChatEntity(role: .function, content: "Function Message!")
        ]
    ))
}
