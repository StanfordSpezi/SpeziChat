//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziSpeechSynthesizer
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
/// ### Accessibility
///
/// The ``ChatView`` provides speech-to-text (recognition) as well as text-to-speech (synthesize) capabilities out of the box via the [`SpeziSpeech`](https://github.com/StanfordSpezi/SpeziSpeech) module, facilitating seamless interaction with the content of the ``ChatView``.
///
/// Speech-to-text capabilities can be activated via the `speechToText` `Bool` parameter in ``init(_:disableInput:speechToText:exportFormat:messagePlaceholder:messagePendingAnimation:hideMessages:)``. By default, this capability is activated and therefore a small microphone button is shown next to the text input field.
///
/// Text-to-speech capabilities can be configured via the `View/speak(_:muted:)` `ViewModifier`. If present, the latest ``ChatEntity/complete`` ``ChatEntity/Role-swift.enum/assistant`` message in the ``Chat`` will be synthesized to natural language speech.
/// In addition, the `View/speechToolbarButton(enabled:muted:)` `ViewModifier` automatically adds a toolbar `Button` to mute or unmute the speech synthesizer, if not disabled via the `enabled` parameter.
/// The `muted` flag enables to track the state of the `Button` or adjust it from the outside.
///
/// ```swift
/// struct ChatTestView: View {
///     @State private var chat: Chat = [
///         ChatEntity(role: .assistant, content: "**Assistant** Message!")
///     ]
///     @State private var muted = false
///
///     var body: some View {
///         ChatView($chat)
///             // Output new completed `assistant` content within the `Chat` via speech
///             .speak(chat, muted: muted)
///             .speechToolbarButton(muted: $muted)
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
    private let disableInput: Bool
    private let speechToText: Bool
    let exportFormat: ChatExportFormat?
    private let messagePlaceholder: String?
    private let messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode?
    private let hideMessages: MessageView.HiddenMessages
    
    @State private var messageInputHeight: CGFloat = 0
    @State private var showShareSheet = false
    
    
    public var body: some View {
        ZStack {
            VStack {
                MessagesView($chat, hideMessages: hideMessages, typingIndicator: messagePendingAnimation, bottomPadding: $messageInputHeight)
                    #if !os(macOS)
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
                    #endif
            }
            VStack {
                Spacer()
                MessageInputView($chat, messagePlaceholder: messagePlaceholder, speechToText: speechToText)
                    .disabled(disableInput)
                    .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
                        runOrScheduleOnMainActor {
                            self.messageInputHeight = newValue + 12
                        }
                    }
            }
        }
            .toolbar {
                if exportEnabled {
                    ToolbarItem(placement: .primaryAction) {
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
                    #if !os(macOS)
                    ShareSheet(sharedItem: exportedChatData, sharedItemType: exportFormat)
                        .presentationDetents([.medium])
                    #endif
                } else {
                    ProgressView()
                        .padding()
                        .presentationDetents([.medium])
                }
            }
            #if os(macOS)
            .onChange(of: showShareSheet) { _, isPresented in
                if isPresented, let exportedChatData, let exportFormat {
                    let shareSheet = ShareSheet(sharedItem: exportedChatData, sharedItemType: exportFormat)
                    shareSheet.show()
                    
                    showShareSheet = false
                }
            }
            // `NSSharingServicePicker` doesn't provide a completion handler as `UIActivityViewController` does,
            // therefore necessitating the deletion of the temporary file on disappearing.
            .onDisappear {
                if let exportFormat {
                    try? FileManager.default.removeItem(
                        at: Self.temporaryExportFilePath(sharedItemType: exportFormat)
                    )
                }
            }
            #endif
    }
    
    private var exportEnabled: Bool {
        exportFormat != nil && chat.contains(where: {
            $0.role == .assistant || $0.role == .user   // Only show export toolbar item if there are visible messages
        })
    }
    
    
    /// - Parameters:
    ///   - chat: The chat that should be displayed.
    ///   - disableInput: Flag if the input view should be disabled.
    ///   - speechToText: Enables speech-to-text (recognition) capabilities of the input field, defaults to `true`.
    ///   - exportFormat: If specified, enables the export of the ``Chat`` displayed in the ``ChatView`` via a share sheet in various formats defined in ``ChatView/ChatExportFormat``.
    ///   - messagePlaceholder: Placeholder text that should be added in the input field.
    ///   - messagePendingAnimation: Parameter to control whether a chat bubble animation is shown.
    ///   - hideMessages: Types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages that should be hidden from the user.
    public init(
        _ chat: Binding<Chat>,
        disableInput: Bool = false,
        speechToText: Bool = true,
        exportFormat: ChatExportFormat? = nil,
        messagePlaceholder: String? = nil,
        messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode? = nil,
        hideMessages: MessageView.HiddenMessages = .all
    ) {
        self._chat = chat
        self.disableInput = disableInput
        self.speechToText = speechToText
        self.exportFormat = exportFormat
        self.messagePlaceholder = messagePlaceholder
        self.hideMessages = hideMessages
        self.messagePendingAnimation = messagePendingAnimation
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ChatView(
            .constant(
                [
                    ChatEntity(role: .user, content: "User Message!"),
                    ChatEntity(role: .hidden(type: .unknown), content: "Hidden Message!"),
                    ChatEntity(role: .assistant, content: "Assistant Message!")
                ]
            ),
            exportFormat: .pdf
        )
    }
}
#endif
