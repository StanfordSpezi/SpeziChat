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
/// This view can be bound to a `Bool` value that controls whether the animation is visible (and active) or not.
///
/// Usage:
/// ```swift
/// struct ChatView: View {
///     @State private var isTyping = true
///
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             MessageView(ChatEntity(role: .assistant, content: "")) {
///                 TypingIndicator($isTyping)
///             }
///         }
///     }
/// }
/// ```
///
public struct TypingIndicator: View {
    @Binding var isVisible: Bool
    @State var isAnimating = false
    
    public var body: some View {
        if isVisible {
            HStack(spacing: 3) {
                ForEach(0..<3) { index in
                    Circle()
                        .opacity(self.isAnimating ? 1 : 0)
                        .foregroundStyle(.tertiary)
                        .animation(
                            Animation
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.2 * Double(index)),
                            value: self.isAnimating
                        )
                }
            }
            .frame(width: 42, height: 12)
            .padding(.vertical, 4)
            .onAppear {
                self.isAnimating = true
            }
        } else {
            EmptyView()
        }
    }
    
    /// - Parameters
    /// - isAnimating: A binding to a `Bool` that determines whether the animation is active.
    init(_ isVisible: Binding<Bool>) {
        self._isVisible = isVisible
    }
}

#Preview {
    TypingIndicator(.constant(true))
}
