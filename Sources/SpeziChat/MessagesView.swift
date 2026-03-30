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
/// ### Usage
///
/// ```swift
/// struct MessagesViewTestView: View {
///     @State private var chat: Chat = [
///         ChatEntity(role: .user, content: "User Message!"),
///         ChatEntity(role: .assistant, content: "Assistant Message!")
///     ]
///
///     var body: some View {
///         MessagesView(chat)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initializers
/// - ``init(_:insets:hideMessages:typingIndicator:)-(Binding<Chat>,_,_,_)``
/// - ``init(_:insets:hideMessages:typingIndicator:)-(Chat,_,_,_)``
public struct MessagesView: View {
    /// Represents a configuration used in the initializer of ``MessagesView`` to specify when to display an animation indicating a pending message from a chat participant.
    ///
    /// ``TypingIndicatorDisplayMode`` has two possible cases:
    /// - ``TypingIndicatorDisplayMode/automatic``: The animation is shown whenever the last message in the chat is from the user,
    ///   and the assistant has not yet begun to respond.
    /// - ``TypingIndicatorDisplayMode/manual(shouldDisplay:)``: The animation will be displayed based on the provided Boolean flag.
    public enum TypingIndicatorDisplayMode {
        case automatic
        case manual(shouldDisplay: Bool)
    }
    
    /// Indicates which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` message roles should be hidden and not visualized.
    ///
    /// - Important: One is only able to customize which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` message roles can be hidden. All messages with other ``ChatEntity/Role-swift.enum``s are shown to the user.
    public enum HiddenMessages: Equatable {
        /// Hide all messages with ``ChatEntity/Role-swift.enum/hidden(type:)`` roles (regardless of the specific hidden message type).
        case all
        /// Adjust which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages should be hidden.
        case custom(hiddenMessageTypes: Set<ChatEntity.HiddenMessageType>)
    }
    
    
    private static let bottomSpacerIdentifier = "Bottom Spacer"
    
    @Binding var chat: Chat
    private let insets: EdgeInsets
    private let hideMessages: HiddenMessages
    private let typingIndicator: TypingIndicatorDisplayMode?
    
    
    #if !os(macOS)
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
    #endif
    
    private var shouldDisplayTypingIndicator: Bool {
        switch self.typingIndicator {
        case .automatic:
            switch self.chat.last?.role {
            case .user: true
            // Ensure that the typing indicator is not shown when the chat is empty (only hidden messages present)
            case .hidden: (self.chat.contains(where: { $0.role == .user || $0.role == .assistant }))
            default: false
            }
        case .manual(let shouldDisplay):
            shouldDisplay
        case .none:
            false
        }
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                scrollViewContent(for: proxy)
            }
            .scrollDismissesKeyboard(.interactively)
            // TODO for some reason the view initially is scrolled a bit too far, and the first user interaction makes it jump into place.
            // FIX!!!! SOMEHOW!!!!!
            .defaultScrollAnchor(.bottom)
        }
    }
    
    
    /// Creates a `MessagesView` displaying an interactive conversation flow.
    ///
    /// - parameter chat: The chat messages that should be displayed.
    /// - parameter hideMessages: Types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages that should be hidden from the user.
    /// - parameter insets: `EdgeInsets` that should be applied within the view
    /// - parameter typingIndicator: Indicates whether a  "three dots" animation should be automatically or manually shown; default value of `nil` will result in no indicator being shown under any condition.
    public init(
        _ chat: Binding<Chat>,
        insets: EdgeInsets = EdgeInsets(),
        hideMessages: HiddenMessages = .all,
        typingIndicator: TypingIndicatorDisplayMode? = nil
    ) {
        self._chat = chat
        self.insets = insets
        self.hideMessages = hideMessages
        self.typingIndicator = typingIndicator
    }
    
    /// Creates a `MessagesView` displaying a static conversation flow.
    ///
    /// - parameter chat: The chat messages that should be displayed.
    /// - parameter hideMessages: Types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages that should be hidden from the user.
    /// - parameter insets: `EdgeInsets` that should be applied within the view
    /// - parameter typingIndicator: Indicates whether a  "three dots" animation should be automatically or manually shown; default value of `nil` will result in no indicator being shown under any condition.
    public init(
        _ chat: Chat,
        insets: EdgeInsets = EdgeInsets(),
        hideMessages: HiddenMessages = .all,
        typingIndicator: TypingIndicatorDisplayMode? = nil
    ) {
        self.init(.constant(chat), insets: insets, hideMessages: hideMessages, typingIndicator: typingIndicator)
    }

    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut) {
            proxy.scrollTo(MessagesView.bottomSpacerIdentifier)
        }
    }
    
    @ViewBuilder
    private func scrollViewContent(for proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 17) {
            ForEach(chat) { message in
                if !shouldHide(message) {
                    MessageView(message)
                }
            }
            if shouldDisplayTypingIndicator {
                TypingIndicator()
            }
            Spacer()
                .frame(height: insets.bottom)
                .id(MessagesView.bottomSpacerIdentifier)
        }
        .padding(.top, insets.top)
        .padding(.horizontal)
//        .onAppear {
//            scrollToBottom(proxy)
//        }
        .onChange(of: chat) {
            scrollToBottom(proxy)
        }
        #if !os(macOS)
        .onReceive(keyboardPublisher) { _ in
            scrollToBottom(proxy)
        }
        #endif
    }
    
    private func shouldHide(_ message: ChatEntity) -> Bool {
        switch message.role {
        case .user, .assistant, .assistantToolCall, .assistantToolResponse:
            false
        case .hidden(let type):
            switch hideMessages {
            case .all:
                true
            case .custom(let hiddenMessageTypes):
                hiddenMessageTypes.contains(type)
            }
        }
    }
}


#if DEBUG
#Preview("Regular Message View") {
    MessagesView([
        ChatEntity(role: .user, text: "User Message!"),
        ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message!"),
        ChatEntity(role: .assistant, text: "Assistant Message!")
    ])
}

#Preview("Unhidden Message View") {
    MessagesView(
        [
            ChatEntity(role: .user, text: "User Message!"),
            ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message (but still visible)!"),
            ChatEntity(role: .assistantToolCall, text: "Assistant Message!"),
            ChatEntity(role: .assistantToolResponse, text: "Assistant Message!f jiodsjfiods \n fudshfdusi"),
            ChatEntity(role: .assistant, text: "Assistant Message!")
        ],
        hideMessages: .custom(hiddenMessageTypes: [])
    )
}
#endif
