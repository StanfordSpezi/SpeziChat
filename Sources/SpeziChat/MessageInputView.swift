//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import PhotosUI
import Speech
import SpeziFoundation
import SpeziSpeechRecognizer
import SpeziViews
import SwiftUI


/// A reusable SwiftUI `View` to handle text-based or speech-based user input.
/// The provided message is attached to the passed ``Chat`` via a SwiftUI `Binding`.
///
/// The input can be either typed out via the iOS keyboard or, if enabled (which is the case by default), provided as voice input and transcribed into written text via the [`SpeziSpeech`](https://github.com/StanfordSpezi/SpeziSpeech) module.
///
/// ### Usage
///
/// ```swift
/// struct MessageInputTestView: View {
///     @State private var chat: Chat = []
///     @State private var disableInput = false
///
///     var body: some View {
///         VStack {
///             Spacer()
///             MessageInputView($chat, placeholder: "TestMessage")
///                 .disabled(disableInput)
///         }
///     }
/// }
/// ```
@available(iOS 26, visionOS 26, *)
struct MessageInputView: View {
    @Binding private var chat: Chat
    private let placeholder: LocalizedStringResource
    private let speechToText: Bool
    
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var message: String = ""
    
    @FocusState<Bool>.Binding private var textFieldIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            inputTextField
            controls
        }
        .padding()
        #if os(iOS)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
        #elseif os(visionOS)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 24))
        #endif
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.75), radius: 0)
        // we want the entire thing to act as a big button where, regardless of where you tap, it always makes the text field first responder.
        .contentShape(Rectangle())
        .onTapGesture {
            textFieldIsFocused = true
        }
        .padding(.horizontal, textFieldIsFocused ? 12 : 6)
        .padding(textFieldIsFocused ? .bottom : [])
        #if canImport(UIKit)
        .background {
            // blur out the scroll view content, as it disappears behind the input overlay.
            // needed bc there is some spacing between the bottom edge of the overlay and the bottom edge of the screen.
            ProgressiveBlur()
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        #endif
    }
    
    
    private var inputTextField: some View {
        TextField(placeholder, text: $message, axis: .vertical)
            .accessibilityLabel(String(localized: "MESSAGE_INPUT_TEXTFIELD", bundle: .module))
            .frame(maxWidth: .infinity)
            .focused($textFieldIsFocused)
    }
    
    
    private var controls: some View {
        HStack {
            Spacer()
            // TODO only sjow tjos cpnditionlly? (or have it append to the already entered text?)
            microphoneButton
            sendButton
        }
    }
    
    private var sendButton: some View {
        Button {
            sendMessageButtonPressed()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .accessibilityLabel(String(localized: "SEND_MESSAGE", bundle: .module))
                .font(.title)
                .foregroundColor(sendButtonForegroundColor)
        }
        .disabled(message.isEmpty)
        .keyboardShortcut(.return, modifiers: .command)
    }
    
    private var microphoneButton: some View {
        Button {
            microphoneButtonPressed()
        } label: {
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
    ///   - placeholder: Placeholder text that should be added in the input field
    ///   - speechToText: Enables speech-to-text (recognition) capabilities of the input field.
    init(
        _ chat: Binding<Chat>,
        placeholder: LocalizedStringResource? = nil, // swiftlint:disable:this function_default_parameter_at_end
        isFocused: FocusState<Bool>.Binding,
        speechToText: Bool = true
    ) {
        self._chat = chat
        self.placeholder = placeholder ?? LocalizedStringResource("Type Your Message…", bundle: .module)
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
        ChatEntity(role: .assistant, text: "Assistant Message!")
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
            if #available(iOS 26, visionOS 26, *) {
                MessageInputView($chat, isFocused: $isFocused)
            }
        }
    }
}
#endif
