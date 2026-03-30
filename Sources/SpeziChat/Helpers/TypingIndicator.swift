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
struct TypingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
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
            }
            .frame(width: 42, height: 12, alignment: .center)
            .padding(.vertical, 4)
            .chatMessageStyle(alignment: .leading)
            .onAppear {
                isAnimating = true
            }
            Spacer(minLength: 32)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("TYPING_INDICATOR", bundle: .module))
    }
}


#if DEBUG
#Preview {
    ScrollView {
        VStack {
            PlainMessageView(ChatEntity(role: .user, text: "User Message!"))
            PlainMessageView(ChatEntity(role: .assistant, text: "Assistant Message!"))
            PlainMessageView(ChatEntity(role: .hidden(type: .unknown), text: "Hidden Message!"))
            PlainMessageView(
                ChatEntity(
                    role: .hidden(type: .unknown),
                    text: "Hidden message! (visible)"
                )
            )
            TypingIndicator()
        }
        .padding()
    }
}
#endif
