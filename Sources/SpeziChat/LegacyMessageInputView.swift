//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import Speech
@_spi(TestingSupport) import SpeziFoundation
import SpeziSpeechRecognizer
import SpeziViews
import SwiftUI


/// A reusable SwiftUI `View` to handle text-based or speech-based user input.
/// The provided message is attached to the passed ``Chat`` via a SwiftUI `Binding`.
struct LegacyMessageInputView: View {
    @Binding private var chat: Chat
    private let messagePlaceholder: String
    private let speechToText: Bool
    
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var message: String = ""
    @FocusState<Bool>.Binding private var textFieldIsFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {    // swiftlint:disable:this closure_body_length
            TextField(messagePlaceholder, text: $message, axis: .vertical)
                .focused($textFieldIsFocused)
                .accessibilityLabel(String(localized: "MESSAGE_INPUT_TEXTFIELD", bundle: .module))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                #if !os(visionOS)
                .padding(.vertical, 8)
                #else
                .padding(.vertical, 12)
                #endif
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        #if !os(macOS)
                        .stroke(Color(.systemGray2), lineWidth: 0.2)
                        #else
                        .stroke(Color(.secondarySystemFill), lineWidth: 0.2)
                        #endif
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.2))
                        }
                        #if os(iOS)
                        // Place speech / send button within message text box on iOS
                        .padding(.trailing, -42)
                        #endif
                }
                .lineLimit(1...5)
                .onSubmit(of: .text) {
                    sendMessageButtonPressed()
                }
                #if os(visionOS)
                // Workaround on visionOS as UI tests are not able to properly set focus on `TextField`
                .if(RuntimeConfig.testMode) { view in
                    view
                        .onTapGesture {
                            textFieldIsFocused = true
                        }
                }
                #endif
            Group {
                if speechToText,
                   speechRecognizer.isAvailable,
                   message.isEmpty || speechRecognizer.isRecording {
                    microphoneButton
                } else {
                    sendButton
                        .disabled(message.isEmpty)
                }
            }
                .frame(minWidth: 33)
        }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            #if os(macOS)
            .onSubmit {
                sendMessageButtonPressed()
            }
            #endif
    }
    
    
    private var sendButton: some View {
        Button(
            action: {
                sendMessageButtonPressed()
            },
            label: {
                Image(systemName: "arrow.up.circle.fill")
                    .accessibilityLabel(String(localized: "SEND_MESSAGE", bundle: .module))
                    .font(.title)
                    .foregroundColor(sendButtonForegroundColor)
            }
        )
            .offset(x: -2, y: -3)
    }
    
    private var microphoneButton: some View {
        Button(
            action: {
                microphoneButtonPressed()
            },
            label: {
                Image(systemName: "mic.fill")
                    .accessibilityLabel(String(localized: "MICROPHONE_BUTTON", bundle: .module))
                    .font(.title2)
                    .foregroundColor(microphoneForegroundColor)
                    .scaleEffect(speechRecognizer.isRecording ? 1.2 : 1.0)
                    .opacity(speechRecognizer.isRecording ? 0.7 : 1.0)
                    .animation(
                        speechRecognizer.isRecording ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default,
                        value: speechRecognizer.isRecording
                    )
            }
        )
            .offset(x: -4, y: -6)
    }
    
    private var sendButtonForegroundColor: Color {
        #if !os(macOS)
        message.isEmpty ? Color(.systemGray5) : .accentColor
        #else
        message.isEmpty ? Color(.gray) : .accentColor
        #endif
    }
    
    private var microphoneForegroundColor: Color {
        #if !os(macOS)
        speechRecognizer.isRecording ? .red : Color(.systemGray2)
        #else
        message.isEmpty ? Color(.gray) : .accentColor
        #endif
    }
    
    /// - Parameters:
    ///   - chat: The chat that should be appended to.
    ///   - messagePlaceholder: Placeholder text that should be added in the input field
    ///   - speechToText: Enables speech-to-text (recognition) capabilities of the input field.
    init(
        _ chat: Binding<Chat>,
        messagePlaceholder: String? = nil, // swiftlint:disable:this function_default_parameter_at_end
        isFocused: FocusState<Bool>.Binding,
        speechToText: Bool = true
    ) {
        self._chat = chat
        self.messagePlaceholder = messagePlaceholder ?? "Message"
        self._textFieldIsFocused = isFocused
        self.speechToText = speechToText
    }
    
    
    private func sendMessageButtonPressed() {
        speechRecognizer.stop()
        chat.append(ChatEntity(role: .user, text: message))
        message = ""
    }
    
    private func microphoneButtonPressed() {
        guard !speechRecognizer.isRecording else {
            speechRecognizer.stop()
            return
        }
        Task {
            for try await result in speechRecognizer.start() {
                if result.bestTranscription.formattedString.contains("send") {
                    sendMessageButtonPressed()
                } else {
                    message = result.bestTranscription.formattedString
                }
            }
        }
    }
}


#if DEBUG
#Preview {
    @Previewable @State var chat = [
        ChatEntity(role: .user, text: "User Message!"),
        ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message!"),
        ChatEntity(role: .assistant(.response), text: "Assistant Message!")
    ]
    @Previewable @FocusState var isFocused
    
    ZStack {
        #if !os(macOS)
        Color(.secondarySystemBackground)
            .ignoresSafeArea()
        #else
        Color(.secondarySystemFill)
            .ignoresSafeArea()
        #endif
        VStack {
            MessagesView($chat)
            LegacyMessageInputView($chat, isFocused: $isFocused)
        }
    }
}
#endif
