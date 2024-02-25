//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// Provides styling for the visualization of a textual ``ChatEntity`` within the ``ChatView``.
struct MessageStyleModifier: ViewModifier {
    let chatAlignment: ChatEntity.Alignment
    let backgroundColorUserChat: Color

    
    private var foregroundColor: Color {
        chatAlignment == .leading ? .primary : .white
    }
    
    private var backgroundColor: Color {
        #if os(macOS)
        chatAlignment == .leading ? Color(.secondarySystemFill) : .accentColor
        #elseif os(visionOS)
        chatAlignment == .leading ? Color(.lightGray) : backgroundColorUserChat
        #else
        chatAlignment == .leading ? Color(.secondarySystemBackground) : .accentColor
        #endif
    }
    
    private var arrowRotation: Angle {
        .degrees(chatAlignment == .leading ? -50 : -130)
    }
    
    private var arrowAlignment: CGFloat {
        chatAlignment == .leading ? -7 : 7
    }
    
    private var overlayAlignment: Alignment {
        chatAlignment == .leading ? .bottomLeading : .bottomTrailing
    }
    
    
    init(chatAlignment: ChatEntity.Alignment, backgroundColorUserChat: Color) {
        self.chatAlignment = chatAlignment
        self.backgroundColorUserChat = backgroundColorUserChat
    }
    

    func body(content: Content) -> some View {
        content
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
                    .offset(x: arrowAlignment),
                alignment: overlayAlignment
            )
            .padding(.horizontal, 4)
    }
}


extension View {
    /// Attach this modifier to `Text`-based content in SwiftUI to format it as a typical chat bubble within a chat view.
    /// The modifier handles text alignment, paddings, colourings, background, as well as the typical chat bubble visualization.
    ///
    /// As visionOS doesn't properly set the `.accentColor` (always "white" in our testing)
    /// during chat export via the `ImageRenderer`, we enable to pass a custom background color for chat user messages.
    ///
    /// ### Usage
    ///
    /// A minimal example can be found below.
    /// See the ``MessageView`` for a more complete example.
    ///
    /// ```swift
    /// struct ChatMessageView: View {
    ///     let chatEntity: ChatEntity
    ///
    ///     var body: some View {
    ///         Text(chatEntity.content)
    ///             .chatMessageStyle(alignment: chatEntity.alignment)
    ///     }
    /// }
    /// ```
    func chatMessageStyle(alignment: ChatEntity.Alignment, backgroundColorUserChat: Color = .accentColor) -> some View {
        self.modifier(
            MessageStyleModifier(chatAlignment: alignment, backgroundColorUserChat: backgroundColorUserChat)
        )
    }
}
