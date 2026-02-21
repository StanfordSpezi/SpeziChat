//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Textual


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
                        StructuredText(markdown: chat.content)
                            .textual.structuredTextStyle(.gitHub)
                            .chatMessageStyle(alignment: chat.alignment)
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
    public init(_ chat: ChatEntity, hideMessages: HiddenMessages = .all) {
        self.chat = chat
        self.hideMessages = hideMessages
    }
}


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
