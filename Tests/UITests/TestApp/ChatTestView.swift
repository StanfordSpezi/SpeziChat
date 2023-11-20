//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SwiftUI


struct ChatTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .assistant, content: "Assistant Message!")
    ]
    
    
    var body: some View {
        ChatView($chat)
            .navigationTitle("SpeziChat")
            .padding(.top, 16)
            .onChange(of: chat) { _, newValue in
                /// Append a new assistant message to the chat after sleeping for 1 second.
                if newValue.last?.role == .user {
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        
                        await MainActor.run {
                            chat.append(.init(role: .assistant, content: "Assistant Message Response!"))
                        }
                    }
                }
            }
    }
}


#Preview {
    ChatTestView()
}
