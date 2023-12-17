//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MessageStyleModifier: ViewModifier {
    let chatAlignment: ChatEntity.Alignment

    
    private var foregroundColor: Color {
        chatAlignment == .leading ? .primary : .white
    }
    
    private var backgroundColor: Color {
        chatAlignment == .leading ? Color(.secondarySystemBackground) : .accentColor
    }
    
    private var multilineTextAlignment: TextAlignment {
        chatAlignment == .leading ? .leading : .trailing
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
    

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(multilineTextAlignment)
            //.frame(maxWidth: .infinity)
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
    func chatMessageStyle(alignment: ChatEntity.Alignment) -> some View {
        self.modifier(MessageStyleModifier(chatAlignment: alignment))
    }
}
