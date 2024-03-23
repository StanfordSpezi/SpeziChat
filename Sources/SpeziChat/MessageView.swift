//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A reusable SwiftUI `View` to display the contents of a ``ChatEntity`` within a typical chat message bubble. This bubble is properly aligned according to the associated ``ChatEntity/Role``.
///
/// Messages with the ``ChatEntity/Role/hidden(type:)`` are hidden. These ``ChatEntity/Role``s are configurable via a parameter in the ``MessageView/init(_:hideMessagesWithRoles:)``.
///
/// ### Usage
///
/// ```swift
/// struct MessageViewTestView: View {
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
///             MessageView(ChatEntity(role: .hidden(type: "system"), content: "System Message (hidden)!"))
///         }
///             .padding()
///     }
/// }
/// ```
public struct MessageView: View {
    /// Contains default values of configurable properties of the ``MessageView``.
    public enum Defaults {
        /// ``ChatEntity`` ``ChatEntity/Role``s that should be hidden by default
        public static let hideMessagesWithRoles: Set<ChatEntity.Role> = [
            .hidden(type: "")
        ]
    }
    
    
    private let chat: ChatEntity
    private let hideMessagesWithRoles: Set<ChatEntity.Role>
    
    
    public var body: some View {
        // Compare raw value of `ChatEntity/Role`s as associated values present
        if !hideMessagesWithRoles.contains(where: { $0.rawValue == chat.role.rawValue }) {
            HStack {
                if chat.alignment == .trailing {
                    Spacer(minLength: 32)
                }
                Text(chat.attributedContent)
                    .chatMessageStyle(alignment: chat.alignment)
                if chat.alignment == .leading {
                    Spacer(minLength: 32)
                }
            }
        }
    }
    
    
    /// - Parameters:
    ///   - chat: The chat message that should be displayed.
    ///   - hideMessagesWithRoles: ``ChatEntity/Role-swift.enum``s that should be hidden from the user.
    public init(_ chat: ChatEntity, hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles) {
        self.chat = chat
        self.hideMessagesWithRoles = hideMessagesWithRoles
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
            MessageView(ChatEntity(role: .hidden(type: "test"), content: "Hidden message! (invisible)"))
            MessageView(ChatEntity(role: .hidden(type: "test"), content: "Hidden message! (visible)"), hideMessagesWithRoles: [])
        }
            .padding()
    }
}
#endif
