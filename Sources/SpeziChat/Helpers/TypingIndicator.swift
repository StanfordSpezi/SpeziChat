//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// Creates a typing indicator animation for pending messages.
/// The animation consists of three dots that fade in and out in a sequential, wave-like pattern.
/// It loops continuously as long as `isAnimating` is `true`.
///
/// Usage:
/// ```swift
/// struct ChatView: View {
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             TypingIndicator()
///         }
///     }
/// }
/// ```
public struct TypingIndicator: View {
    @State var isAnimating = false
    
    
    public var body: some View {
        HStack {
            HStack(spacing: 3) {
                ForEach(0..<3) { index in
                    Circle()
                        .opacity(isAnimating ? 1 : 0)
                        .foregroundStyle(.tertiary)
                        .animation(
                            Animation
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.2 * Double(index)),
                            value: isAnimating
                        )
                        .frame(width: 10)
                }
                    .accessibilityIdentifier(String(localized: "TYPING_INDICATOR", bundle: .module))
            }
                .frame(width: 42, height: 12, alignment: .center)
                .padding(.vertical, 4)
                .chatMessageStyle(alignment: .leading)
                .task {
                    isAnimating = true
                }
            
            Spacer(minLength: 32)
        }
    }
}


#if DEBUG
#Preview {
    ScrollView {
        VStack {
            MessageView(ChatEntity(role: .user, content: "User Message!"))
            MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
            MessageView(ChatEntity(role: .hidden(type: "test"), content: "Hidden Message!"))
            MessageView(ChatEntity(role: .hidden(type: "test"), content: "Hidden Message! (still visible)"), hideMessagesWithRoles: [])
            TypingIndicator()
        }
        .padding()
    }
}
#endif
