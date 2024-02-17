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
    enum Defaults {
        static let initialMessage: AttributedString = {
            guard let attributedString = try? AttributedString(markdown: "**Assistant** Message!") else {
                preconditionFailure("Mock Chat Content is not parsable as an AttributedString.")
            }
            
            return attributedString
        }()
        
        static let responseMessage: AttributedString = {
            guard let attributedString = try? AttributedString(markdown: "**Assistant** Message Response!") else {
                preconditionFailure("Mock Chat Content is not parsable as an AttributedString.")
            }
            
            return attributedString
        }()
    }
    
    
    @State private var chat: Chat = [
        ChatEntity(role: .assistant, content: Defaults.initialMessage)
    ]
    
    
    var body: some View {
        ChatView($chat, exportFormat: .pdf, messagePendingAnimation: .automatic)
            .navigationTitle("SpeziChat")
            .padding(.top, 16)
            .onChange(of: chat) { _, newValue in
                /// Append a new assistant message to the chat after sleeping for 1 second.
                if newValue.last?.role == .user {
                    Task {
                        try await Task.sleep(for: .seconds(5))
                        
                        await MainActor.run {
                            chat.append(.init(role: .assistant, content: Defaults.responseMessage))
                        }
                    }
                }
            }
    }
}


#Preview {
    ChatTestView()
}
