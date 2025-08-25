//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(AVFoundation)
import AVFoundation
#endif


/// A reusable SwiftUI `View` to display the contents of a ``ChatEntity`` within a typical chat message bubble. This bubble is properly aligned according to the associated ``ChatEntity/Role``.
///
/// Messages with the ``ChatEntity/Role/hidden(type:)`` are hidden. These ``ChatEntity/Role``s are configurable via a parameter in the ``MessageView/init(_:hideMessages:)``.
///
/// ### Usage
///
/// ```swift
/// struct MessageViewTestView: View {
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
///             MessageView(ChatEntity(role: .hidden(type: .unknown), content: "System Message (hidden)!"))
///         }
///             .padding()
///     }
/// }
/// ```
public struct MessageView: View {
    /// Indicates which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` message roles should be hidden and not visualized.
    ///
    /// - Important: One is only able to customize which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` message roles can be hidden. All messages with other ``ChatEntity/Role-swift.enum``s are shown to the user.
    public enum HiddenMessages: Equatable {
        /// Hide all messages with ``ChatEntity/Role-swift.enum/hidden(type:)`` roles (regardless of the specific hidden message type).
        case all
        /// Adjust which types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages should be hidden.
        case custom(hiddenMessageTypes: Set<ChatEntity.HiddenMessageType>)
    }
    
    
    private let chat: ChatEntity
    private let hideMessages: HiddenMessages
    
    
    private var shouldDisplayMessage: Bool {
        switch chat.role {
        case .user, .assistant, .assistantToolCall, .assistantToolResponse: return true
        case .hidden(let type):
            if case .custom(let hiddenMessageTypes) = hideMessages {
                return !hiddenMessageTypes.contains(type)
            }
            
            return false
        }
    }
    
    private var isToolInteraction: Bool {
        switch chat.role {
        case .assistantToolCall, .assistantToolResponse:
            true
        default:
            false
        }
    }
    
    // exposes copyable text for “normal” messages and hides it for tool interactions
        private var copyText: String? {
            guard !isToolInteraction else { return nil }
            let raw = chat.content            // ChatEntity is initialized with `content: String`
            return raw.isEmpty ? nil : raw
        }
    
    //the following controls whether text is selectable; true if message is long-pressed and 'select' is selected
    @Binding private var selectionMode: Bool
    
    public var body: some View {
        if shouldDisplayMessage {
            HStack {
                if chat.alignment == .trailing {
                    Spacer(minLength: 32)
                }
                VStack(alignment: chat.horziontalAlignment) {
                    if isToolInteraction {
                        ToolInteractionView(entity: chat)
                    } else {
                        // build the bubble once
                            let bubble = Text(chat.attributedContent)
                                .chatMessageStyle(alignment: chat.alignment)

                            // choose the concrete variant via ViewBuilder, not a ternary
                        Group {
                            if selectionMode {
                                bubble
                                    .textSelection(.enabled)
                                    .background(           // publish bubble frame in a named space
                                        GeometryReader { proxy in
                                            Color.clear.preference(
                                                key: SelectedBubbleFrameKey.self,
                                                value: proxy.frame(in: .named("ChatSpace"))
                                            )
                                        }
                                    )
                                    .zIndex(2)
                            } else {
                                bubble
                                    .textSelection(.disabled)
                                //Attach a context menu to that Text so a long press shows Copy.
                                    .contextMenu {
                                        if let t = copyText {
                                            Button(String(localized: "Copy")) {
                                                #if canImport(UIKit)
                                                UIPasteboard.general.string = t
                                                #elseif canImport(AppKit)
                                                NSPasteboard.general.clearContents()
                                                NSPasteboard.general.setString(t, forType: .string)
                                                #endif
                                            }
                                            //Select option goes here
                                            Button(String(localized: "Select")) {
                                                selectionMode = true
                                            }
                                        }
                                        
                                    }
                            }
                        }
                        //voiceover rotor action goes here
                            .accessibilityAction(named: Text(String(localized: "Copy"))) {
                                guard let t = copyText else { return }
                                #if canImport(UIKit)
                                UIPasteboard.general.string = t
                                #elseif canImport(AppKit)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(t, forType: .string)
                                #endif
                            }
                        
                    }
                }
                
                if chat.alignment == .leading {
                    Spacer(minLength: 32)
                }
            }
        }
    }
    
    
    /// - Parameters:
    ///   - chat: The chat message that should be displayed.
    ///   - hideMessages: Types of ``ChatEntity/Role-swift.enum/hidden(type:)`` messages that should be hidden from the user.
    ///   - selectionMode: boolean determining if we are in 'select' mode, which we enter when a user presses 'select' buttton in a chat's context menu
    public init(_ chat: ChatEntity, hideMessages: HiddenMessages = .all, selectionMode: Binding<Bool> = .constant(false)) {
        self.chat = chat
        self.hideMessages = hideMessages
        self._selectionMode = selectionMode
    }
}

//for select option in context menu
struct SelectedBubbleFrameKey: PreferenceKey {
    static let defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}


//speech helper function for playback of text in long press
#if canImport(AVFoundation)
import AVFoundation

@MainActor                 // <— key line: confine everything to the main actor
final class Speech {
    static let shared = Speech()
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String,
               language: String? = nil,
               rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let u = AVSpeechUtterance(string: text)
        if let lang = language, let voice = AVSpeechSynthesisVoice(language: lang) {
            u.voice = voice
        }
        u.rate = rate
        synth.speak(u)
    }

    func stop() { synth.stopSpeaking(at: .immediate) }
    var isSpeaking: Bool { synth.isSpeaking }
}
#endif

#if DEBUG
#Preview {
    ScrollView {
        VStack {
            MessageView(ChatEntity(role: .user, content: "User Message!"))
            MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
            MessageView(ChatEntity(role: .user, content: "Long User Message that spans over two lines!"))
            MessageView(ChatEntity(role: .assistant, content: "Long Assistant Message that spans over two lines!"))
            MessageView(ChatEntity(role: .assistantToolCall, content: "assistent_too_call(parameter: value)"))
            MessageView(ChatEntity(role: .assistantToolResponse, content: """
            {
                "some": "response"
            }
            """))
            MessageView(ChatEntity(role: .hidden(type: .unknown), content: "Hidden message! (invisible)"))
            MessageView(
                ChatEntity(
                    role: .hidden(type: .unknown),
                    content: "Hidden message! (visible)"
                ),
                hideMessages: .custom(hiddenMessageTypes: [])
            )
        }
            .padding()
    }
}
#endif
