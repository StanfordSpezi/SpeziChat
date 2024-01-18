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
///
public struct TypingIndicator: View {
    @State var isAnimating = false
    
    public var body: some View {
        HStack {
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
                .accessibilityIdentifier(String(localized: "PENDING_MESSAGE_ANIMATION", bundle: .module))
            }
            .frame(width: 42, height: 12, alignment: .leading)
            .padding(.vertical, 4)
            .onAppear {
                self.isAnimating = true
            }
            .chatMessageStyle(alignment: .leading)
            Spacer(minLength: 32)
        }
    }
}

#Preview {
    TypingIndicator()
}
