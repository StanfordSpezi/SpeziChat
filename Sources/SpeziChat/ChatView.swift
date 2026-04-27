//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import SpeziFoundation
public import SwiftUI


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
    private enum ExportAvailability {
        /// The export functionality is wholly unavailable
        case unavailable
        /// The export functionality is available, and might or might not be enabled.
        case available(enabled: Bool)
    }
    
    @Environment(\.chatViewInsets) private var insets
    @Binding private var chat: Chat
    private let disableInput: Bool
    private let speechToText: Bool
    private let exportFormat: ChatExportFormat?
    private let messagePlaceholder: LocalizedStringResource?
    private let messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode?
    private let messagesVisibility: MessagesView.MessagesVisibility
    
    @State private var showShareSheet = false
    @FocusState private var inputTextFieldIsFocused
    
    public var body: some View {
        chatView
            .safeAreaInset(edge: .bottom) {
                inputView
            }
        .toolbar {
            toolbar
        }
        .sheet(isPresented: $showShareSheet) {
            if let exportFormat, let exportedData = Self.export(chat, as: exportFormat) {
                #if !os(macOS)
                ShareSheet(sharedItem: exportedData, sharedItemType: exportFormat)
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
            if isPresented, let exportFormat, let exportedData = Self.export(chat, as: exportFormat) {
                let shareSheet = ShareSheet(sharedItem: exportedData, sharedItemType: exportFormat)
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
    
    private var exportAvailability: ExportAvailability {
        guard exportFormat != nil else {
            return .unavailable
        }
        return .available(enabled: chat.contains {
            // only enable the export toolbar item if there are visible messages
            $0.role == .assistant(.response) || $0.role == .user
        })
    }
    
    private var chatView: some View {
        MessagesView(
            $chat,
            insets: EdgeInsets(
                top: insets.top,
                leading: insets.leading,
                bottom: insets.bottom + 8, // TODO???
                trailing: insets.trailing
            ),
            messagesVisibility: messagesVisibility,
            typingIndicator: messagePendingAnimation
        )
        #if !os(macOS)
        .onTapGesture {
            inputTextFieldIsFocused = false
        }
        #endif
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        switch exportAvailability {
        case .unavailable:
            ToolbarItem { EmptyView() }
        case .available(let enabled):
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .accessibilityLabel(Text("EXPORT_CHAT_BUTTON", bundle: .module))
                }
                .disabled(!enabled)
            }
        }
    }
    
    @ViewBuilder private var inputView: some View {
        let isMacOS = {
            #if os(macOS)
            true
            #else
            false
            #endif
        }()
        if !isMacOS, #available(iOS 26, visionOS 26, *) {
            MessageInputView($chat, placeholder: messagePlaceholder, isFocused: $inputTextFieldIsFocused, speechToText: speechToText)
                .disabled(disableInput)
        } else {
            LegacyMessageInputView(
                $chat,
                messagePlaceholder: messagePlaceholder.map { String(localized: $0) },
                isFocused: $inputTextFieldIsFocused,
                speechToText: speechToText
            )
            .disabled(disableInput)
        }
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
        messagePlaceholder: LocalizedStringResource? = nil,
        messagePendingAnimation: MessagesView.TypingIndicatorDisplayMode? = nil,
        messagesVisibility: MessagesView.MessagesVisibility = .default
    ) {
        self._chat = chat
        self.disableInput = disableInput
        self.speechToText = speechToText
        self.exportFormat = exportFormat
        self.messagePlaceholder = messagePlaceholder
        self.messagesVisibility = messagesVisibility
        self.messagePendingAnimation = messagePendingAnimation
    }
}


extension EnvironmentValues {
    @Entry fileprivate var chatViewInsets = EdgeInsets()
}


extension View {
    /// Specifies extra insets that should be added to a ``ChatView``.
    ///
    /// - Note: Prefer this modifier over applying a padding to the ``ChatView`` directly.
    ///     Directly applied padding will cause the `ChatView`'s inner `ScrollView` to no longer extend its contents below the NavigationBar or underneath the system keyboard.
    ///     This modifier instead applies the insets within the `ScrollView`.
    public func chatViewInsets(_ insets: EdgeInsets) -> some View {
        transformEnvironment(\.chatViewInsets) { current in
            current.top += insets.top
            current.bottom += insets.bottom
            current.leading += insets.leading
            current.trailing += insets.trailing
        }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ChatView(
            .constant(
                [
                    ChatEntity(role: .user, text: "User Message!"),
                    ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message!"),
                    ChatEntity(role: .assistant(.response), text: "Assistant Message!")
                ]
            ),
            exportFormat: .pdf
        )
    }
}
#endif
