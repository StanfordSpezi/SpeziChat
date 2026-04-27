//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import Combine
public import SwiftUI


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
    
    public struct MessagesVisibility {
        /// Indicates which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` message roles should be hidden from the chat.
        public enum HiddenMessages: Equatable {
            /// Hide all messages with a `hidden` role (regardless of the message's ``ChatEntity/HiddenMessageType``).
            case all
            /// Displays all hidden messages, except some, based on their ``ChatEntity/HiddenMessageType``.
            case custom(Set<ChatEntity.HiddenMessageType>)
            
            /// No messages should be hidden.
            public static var none: Self {
                .custom([])
            }
        }
        
        public static var `default`: Self {
            .init(hiddenMessages: .all, functionCalls: .hidden)
        }
        
        let hiddenMessages: HiddenMessages
        let functionCalls: Visibility
        let thinking: Visibility
        
        public init(
            hiddenMessages: HiddenMessages,
            functionCalls: Visibility = .automatic,
            thinking: Visibility = .automatic
        ) {
            self.hiddenMessages = hiddenMessages
            self.functionCalls = functionCalls
            self.thinking = thinking
        }
    }
    
    
    private static let bottomSpacerIdentifier = "Bottom Spacer"
    
    @Binding private var chat: Chat
    private let insets: EdgeInsets
    private let messagesVisibility: MessagesVisibility
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
            switch chat.last?.role {
            case .user:
                true
            // Ensure that the typing indicator is not shown when the chat is empty (only hidden messages present)
            case .hidden:
                chat.contains { $0.role == .user || $0.role == .assistant(.response) }
            default:
                false
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
            #if !os(visionOS)
            .scrollDismissesKeyboard(.interactively)
            #endif
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
        messagesVisibility: MessagesVisibility = .default,
        typingIndicator: TypingIndicatorDisplayMode? = nil
    ) {
        self._chat = chat
        self.insets = insets
        self.messagesVisibility = messagesVisibility
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
        messagesVisibility: MessagesVisibility = .default,
        typingIndicator: TypingIndicatorDisplayMode? = nil
    ) {
        self.init(
            .constant(chat),
            insets: insets,
            messagesVisibility: messagesVisibility,
            typingIndicator: typingIndicator
        )
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
            // TODO need to have a spacer here to push things up when the chat is very short
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
        case .user, .assistant(.response), .assistant(.toolCall), .assistant(.toolResponse):
            false
        case .assistant(.thinking):
            switch messagesVisibility.thinking {
            case .automatic, .visible:
                // We only show thinking messages while the operation is still active.
                // Once it completes, the chat entity is no longer displayed.
                false // message.complete
            case .hidden:
                true
            }
        case .hidden(let type):
            switch messagesVisibility.hiddenMessages {
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
        ChatEntity(role: .assistant(.response), text: "Assistant Message!")
    ])
}

#Preview("Unhidden Message View") {
    MessagesView(
        [
            ChatEntity(role: .user, text: "User Message!"),
            ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message (but still visible)!"),
            ChatEntity(role: .assistant(.toolCall), text: "Assistant Message!"),
            ChatEntity(role: .assistant(.toolResponse), text: "Assistant Message!f jiodsjfiods \n fudshfdusi"),
            ChatEntity(role: .assistant(.response), text: "Assistant Message!")
        ],
        messagesVisibility: .init(hiddenMessages: .none, functionCalls: .automatic)
    )
}
#endif
