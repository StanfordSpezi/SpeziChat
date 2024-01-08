//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import SwiftUI


/// Displays a ``Chat`` containing multiple ``ChatEntity``s with different ``ChatEntity/Role``s in a typical chat-like fashion.
/// The `View` automatically scrolls down to the newest message that is added to the passed ``Chat`` SwiftUI `Binding`.
///
/// Depending on the parameters, ``ChatEntity``s with certain ``ChatEntity/Role``s are hidden from the `View`.
/// The ``MessagesView`` is shifted from the bottom by a configurable parameter which is important for input fields, e.g., ``MessageInputView``.
///
///
/// ```swift
/// struct MessagesViewTestView: View {
///     @State private var chat: Chat = [
///         ChatEntity(role: .user, content: "User Message!"),
///         ChatEntity(role: .assistant, content: "Assistant Message!")
///     ]
///
///     var body: some View {
///         MessagesView($chat)
///     }
/// }
/// ```
public struct MessagesView: View {
    private static let bottomSpacerIdentifier = "Bottom Spacer"
    
    @Binding private var chat: Chat
    @Binding private var bottomPadding: CGFloat
    private let hideMessagesWithRoles: Set<ChatEntity.Role>
    
    
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(Array(chat.enumerated()), id: \.offset) { _, message in
                        MessageView(message, hideMessagesWithRoles: hideMessagesWithRoles)
                    }
                    Spacer()
                        .frame(height: bottomPadding)
                        .id(MessagesView.bottomSpacerIdentifier)
                }
                    .padding(.horizontal)
                    .onAppear {
                        scrollToBottom(scrollViewProxy)
                    }
                    .onChange(of: chat) {
                        scrollToBottom(scrollViewProxy)
                    }
                    .onReceive(keyboardPublisher) { _ in
                        scrollToBottom(scrollViewProxy)
                    }
            }
        }
    }
    
    
    /// - Parameters:
    ///   - chat: The chat messages that should be displayed.
    ///   - bottomPadding: A fixed bottom padding for the messages view.
    ///   - hideMessagesWithRoles: The .system and .function roles are hidden from message view
    public init(
        _ chat: Chat,
        hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles,
        bottomPadding: CGFloat = 0
    ) {
        self._chat = .constant(chat)
        self.hideMessagesWithRoles = hideMessagesWithRoles
        self._bottomPadding = .constant(bottomPadding)
    }

    /// - Parameters:
    ///   - chat: The chat messages that should be displayed.
    ///   - bottomPadding: A bottom padding for the messages view.
    ///   - hideMessagesWithRoles: Defines which messages should be hidden based on the passed in message roles.
    public init(
        _ chat: Binding<Chat>,
        hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles,
        bottomPadding: Binding<CGFloat> = .constant(0)
    ) {
        self._chat = chat
        self.hideMessagesWithRoles = hideMessagesWithRoles
        self._bottomPadding = bottomPadding
    }

    
    private func scrollToBottom(_ scrollViewProxy: ScrollViewProxy) {
        withAnimation(.easeOut) {
            scrollViewProxy.scrollTo(MessagesView.bottomSpacerIdentifier)
        }
    }
}


#Preview {
    MessagesView(
        [
            ChatEntity(role: .system, content: "System Message!"),
            ChatEntity(role: .system, content: "System Message (hidden)!"),
            ChatEntity(role: .function(name: "test_function"), content: "Function Message!"),
            ChatEntity(role: .user, content: "User Message!"),
            ChatEntity(role: .assistant, content: "Assistant Message!")
        ]
    )
}
