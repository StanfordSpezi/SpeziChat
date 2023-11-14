//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import Speech
import SpeziSpeechRecognizer
import SwiftUI


/// A reusable SwiftUI `View` to handle text-based or speech-based user input.
/// The provided message is attached to the passed ``Chat`` via a SwiftUI `Binding`.
///
/// The input can be either typed out via the iOS keyboard or provided as voice input and transcribed into written text.
///
/// One can get the size of the typed message, which can vary dependent on the message length, via the ``MessageInputViewHeightKey`` SwiftUI PreferenceKey`.
///
///
/// ```swift
/// struct MessageInputTestView: View {
///     @State private var chat: Chat = []
///     @State private var disableInput = false
///     /// Indicates the height of the input message field, necessary for properly shifting
///     /// other view content.
///     @State private var messageInputHeight: CGFloat = 0
///
///     var body: some View {
///         VStack {
///             Spacer()
///             MessageInputView($chat, messagePlaceholder: "TestMessage")
///                 .disabled(disableInput)
///                 /// Get the height of the `MessageInputView` via a SwiftUI `PreferenceKey`
///                 .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
///                     messageInputHeight = newValue
///                 }
///         }
///     }
/// }
/// ```
public struct MessageInputView: View {
    @Binding private var chat: Chat
    private let messagePlaceholder: String
    
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var message: String = ""
    @State private var messageViewHeight: CGFloat = 0
    
    
    public var body: some View {
        HStack(alignment: .bottom) {
            TextField(messagePlaceholder, text: $message, axis: .vertical)
                .accessibilityLabel(String(localized: "MESSAGE_INPUT_TEXTFIELD", bundle: .module))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(UIColor.systemGray2), lineWidth: 0.2)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.2))
                        }
                        .padding(.trailing, -42)
                }
                .lineLimit(1...5)
            Group {
                if speechRecognizer.isAvailable && (message.isEmpty || speechRecognizer.isRecording) {
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
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            messageViewHeight = proxy.size.height
                        }
                        .onChange(of: message) {
                            messageViewHeight = proxy.size.height
                        }
                }
            }
            .messageInputViewHeight(messageViewHeight)
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
                    .foregroundColor(
                        message.isEmpty ? Color(.systemGray5) : .accentColor
                    )
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
                    .foregroundColor(
                        speechRecognizer.isRecording ? .red : Color(.systemGray2)
                    )
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
    
    
    /// - Parameters:
    ///   - chat: The chat that should be appended to.
    ///   - messagePlaceholder: Placeholder text that should be added in the input field
    public init(
        _ chat: Binding<Chat>,
        messagePlaceholder: String? = nil
    ) {
        self._chat = chat
        self.messagePlaceholder = messagePlaceholder ?? "Message"
    }
    
    
    private func sendMessageButtonPressed() {
        speechRecognizer.stop()
        chat.append(ChatEntity(role: .user, content: message))
        message = ""
    }
    
    private func microphoneButtonPressed() {
        if speechRecognizer.isRecording {
            speechRecognizer.stop()
        } else {
            Task {
                do {
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
    }
}


#Preview {
    @State var chat = [
        ChatEntity(role: .system, content: "System Message!"),
        ChatEntity(role: .system, content: "System Message (hidden)!"),
        ChatEntity(role: .function, content: "Function Message!"),
        ChatEntity(role: .user, content: "User Message!"),
        ChatEntity(role: .assistant, content: "Assistant Message!")
    ]
    
    
    return ZStack {
        Color(.secondarySystemBackground)
            .ignoresSafeArea()
        VStack {
            MessagesView($chat)
            MessageInputView($chat)
        }
            .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
                print("New MessageView height: \(newValue)")
            }
    }
}
