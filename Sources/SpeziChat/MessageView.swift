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
/// Messages with specific system ``ChatEntity/Role``s are hidden. Those ``ChatEntity/Role``s are configurable via a parameter.
/// 
///
/// ```swift
/// struct MessageViewTestView: View {
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
///             MessageView(ChatEntity(role: .system, content: "System Message (hidden)!"))
///         }
///             .padding()
///     }
/// }
/// ```
public struct MessageView: View {
    /// Contains default values of configurable properties of the ``MessageView``.
    public enum Defaults {
        /// ``ChatEntity`` ``ChatEntity/Role``s that should be hidden by default
        public static let hideMessagesWithRoles: Set<ChatEntity.Role> = [.system, .function]
    }
    
    
    private let chat: ChatEntity
    private let hideMessagesWithRoles: Set<ChatEntity.Role>

    
    private var foregroundColor: Color {
        chat.alignment == .leading ? .primary : .white
    }
    
    private var backgroundColor: Color {
        chat.alignment == .leading ? Color(.secondarySystemBackground) : .accentColor
    }
    
    private var multilineTextAllignment: TextAlignment {
        chat.alignment == .leading ? .leading : .trailing
    }
    
    private var arrowRotation: Angle {
        .degrees(chat.alignment == .leading ? -50 : -130)
    }
    
    private var arrowAllignment: CGFloat {
        chat.alignment == .leading ? -7 : 7
    }
    
    public var body: some View {
        if !hideMessagesWithRoles.contains(chat.role) {
            HStack {
                if chat.alignment == .trailing {
                    Spacer(minLength: 32)
                }
                Text(chat.content)
                    .multilineTextAlignment(multilineTextAllignment)
                    .frame(idealWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(foregroundColor)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        Image(systemName: "arrowtriangle.left.fill")
                            .accessibilityHidden(true)
                            .foregroundColor(backgroundColor)
                            .rotationEffect(arrowRotation)
                            .offset(x: arrowAllignment),
                        alignment: chat.alignment == .leading ? .bottomLeading : .bottomTrailing
                    )
                    .padding(.horizontal, 4)
                if chat.alignment == .leading {
                    Spacer(minLength: 32)
                }
            }
        }
    }
    
    
    /// - Parameters:
    ///   - chat: The chat message that should be displayed.
    ///   - hideMessagesWithRoles: If .system and/or .function messages should be hidden from the chat overview.
    public init(_ chat: ChatEntity, hideMessagesWithRoles: Set<ChatEntity.Role> = MessageView.Defaults.hideMessagesWithRoles) {
        self.chat = chat
        self.hideMessagesWithRoles = hideMessagesWithRoles
    }
}


#Preview {
    ScrollView {
        VStack {
            MessageView(ChatEntity(role: .system, content: "System Message!"), hideMessagesWithRoles: [])
            MessageView(ChatEntity(role: .system, content: "System Message (hidden)!"))
            MessageView(ChatEntity(role: .function, content: "Function Message!"), hideMessagesWithRoles: [.system])
            MessageView(ChatEntity(role: .user, content: "User Message!"))
            MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
        }
        .padding()
    }
}
