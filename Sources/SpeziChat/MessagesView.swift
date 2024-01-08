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
    /// Offers configuration of when to show an animation indicating a pending message from assistant:
    /// either (a) whenever the last message in the chat is from the user but not even a partial response from the assistant has arrived,
    /// or (b) depending on `shouldDisplay`, some explicitly stated source of truth.
    /// Useful as a visual cue to the user that the LLM has started processing the message.
    public enum LoadingDisplayMode {
        case automatic
        case manual(shouldDisplay: Binding<Bool>)
    }
    
    private static let bottomSpacerIdentifier = "Bottom Spacer"
    
    @Binding private var chat: Chat
    @Binding private var bottomPadding: CGFloat
    private let hideMessagesWithRoles: Set<ChatEntity.Role>
    private let loadingDisplayMode: LoadingDisplayMode
    
    
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
    
    private var shouldDisplayTypingIndicator: Bool {
        switch self.loadingDisplayMode {
        case .automatic:
            self.chat.last?.role == .user
        case .manual(let shouldDisplay):
            shouldDisplay.wrappedValue
        }
    }
    
    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(Array(chat.enumerated()), id: \.offset) { _, message in
                        MessageView(message, hideMessagesWithRoles: hideMessagesWithRoles)
                    }
                    if shouldDisplayTypingIndicator {
                        TypingIndicator()
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
    ///   - loadingDisplayMode: Indicates whether a  "three dots" animation should be automatically or manually shown.
    ///   - hideMessagesWithRoles: The .system and .function roles are hidden from message view
    public init(
        _ chat: Chat,
        hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles,
        loadingDisplayMode: LoadingDisplayMode = .automatic,
        bottomPadding: CGFloat = 0
    ) {
        self._chat = .constant(chat)
        self.hideMessagesWithRoles = hideMessagesWithRoles
        self.loadingDisplayMode = loadingDisplayMode
        self._bottomPadding = .constant(bottomPadding)
    }

    /// - Parameters:
    ///   - chat: The chat messages that should be displayed.
    ///   - bottomPadding: A bottom padding for the messages view.
    ///   - loadingDisplayMode: Indicates whether a  "three dots" animation should be automatically or manually shown.
    ///   - hideMessagesWithRoles: Defines which messages should be hidden based on the passed in message roles.
    public init(
        _ chat: Binding<Chat>,
        hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles,
        loadingDisplayMode: LoadingDisplayMode = .automatic,
        bottomPadding: Binding<CGFloat> = .constant(0)
    ) {
        self._chat = chat
        self.hideMessagesWithRoles = hideMessagesWithRoles
        self.loadingDisplayMode = loadingDisplayMode
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
