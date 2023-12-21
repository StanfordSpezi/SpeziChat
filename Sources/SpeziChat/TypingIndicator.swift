//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public struct TypingIndicator: View {
    @Binding var isAnimating: Bool
    
    public var body: some View {
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
    }
    
    init(_ isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
    }
}

#Preview {
    TypingIndicator(.constant(true))
}
