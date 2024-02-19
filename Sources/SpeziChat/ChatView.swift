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
/// ### Usage
///
/// A minimal example of the ``ChatView`` can be found below.
/// Ensure that the `ChatTestView` is wrapped within a SwiftUI `NavigationStack` in order to specify the `.navigationTitle()` view modifier.
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
///
/// ### Export of Chat
///
/// The ``ChatView`` provides functionality to export the visualized ``Chat`` as a PDF document, JSON representation, or textual UTF-8 file (see ``ChatView/ChatExportFormat``).
/// The export is enabled via an iOS-typical Share Sheet (also called Activity View: https://developer.apple.com/design/human-interface-guidelines/activity-views)
/// that is trigged by a click on the Share `Botton` in the `.toolbar()`.
///
/// A minimal example enabling the export of the ``Chat`` as a PDF document looks like the following.
/// Ensure that the `ChatExportTestView` is wrapped within a SwiftUI `NavigationStack`.
///
/// ```swift
/// struct ChatExportTestView: View {
///     @State private var chat: Chat = [
///         // ...
///     ]
///
///     var body: some View {
///         ChatView($chat, exportFormat: .pdf)
///             .navigationTitle("SpeziChat")
///     }
/// }
/// ```
public struct ChatView: View {
    @Binding var chat: Chat
    var disableInput: Bool
    let exportFormat: ChatExportFormat?
    let messagePlaceholder: String?
    let messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode?
    
    @State var messageInputHeight: CGFloat = 0
    @State private var showShareSheet = false
    
    
    public var body: some View {
        ZStack {
            VStack {
                MessagesView($chat, typingIndicator: messagePendingAnimation, bottomPadding: $messageInputHeight)
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
                        messageInputHeight = newValue + 8
                    }
            }
        }
        .toolbar {
            if exportEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel(Text("EXPORT_CHAT_BUTTON", bundle: .module))
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let exportedChatData, let exportFormat {
                ShareSheet(sharedItem: exportedChatData, sharedItemType: exportFormat)
                    .presentationDetents([.medium])
            } else {
                ProgressView()
                    .padding()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var exportEnabled: Bool {
        exportFormat != nil && chat.contains(where: {
            $0.role == .assistant || $0.role == .user   // Only show export toolbar item if there are visible messages
        })
    }
    
    
    /// - Parameters:
    ///   - chat: The chat that should be displayed.
    ///   - disableInput: Flag if the input view should be disabled.
    ///   - exportFormat: If specified, enables the export of the ``Chat`` displayed in the ``ChatView`` via a share sheet in various formats defined in ``ChatView/ChatExportFormat``.
    ///   - messagePlaceholder: Placeholder text that should be added in the input field.
    ///   - messagePendingAnimation: Parameter to control whether a chat bubble animation is shown.
    public init(
        _ chat: Binding<Chat>,
        disableInput: Bool = false,
        exportFormat: ChatExportFormat? = nil,
        messagePlaceholder: String? = nil,
        messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode? = nil
    ) {
        self._chat = chat
        self.disableInput = disableInput
        self.exportFormat = exportFormat
        self.messagePlaceholder = messagePlaceholder
        self.messagePendingAnimation = messagePendingAnimation
    }
}


#Preview {
    NavigationStack {
        ChatView(
            .constant(
                [
                    ChatEntity(role: .system, content: "System Message!"),
                    ChatEntity(role: .system, content: "System Message (hidden)!"),
                    ChatEntity(role: .user, content: "User Message!"),
                    ChatEntity(role: .assistant, content: "Assistant Message!"),
                    ChatEntity(role: .function(name: "test_function"), content: "Function Message!")
                ]
            ),
            exportFormat: .pdf
        )
    }
}
