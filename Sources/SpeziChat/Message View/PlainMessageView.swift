//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Textual


/// Displays the contents of a ``ChatEntity``, without applying any styling based on the context and role of the message..
struct PlainMessageView: View {
    private let message: ChatEntity
    
    var body: some View {
        switch message.content {
        case .text(let text):
            MarkdownView(text: text)
        }
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
}


extension PlainMessageView {
    struct MarkdownView: View { // TODO move elsewhere!
        let text: String
        
        var body: some View {
            StructuredText(markdown: text)
                .textual.inlineStyle(
                    InlineStyle.gitHub
                        .code(.monospaced, .fontScale(0.85), .backgroundColor(.clear))
                )
                .textual.structuredTextStyle(.gitHub)
        }
    }
}


#if DEBUG
#Preview {
    ScrollView {
        VStack {
            PlainMessageView(ChatEntity(role: .user, text: "User Message!"))
            PlainMessageView(ChatEntity(role: .assistant(.response), text: "Assistant Message!"))
            PlainMessageView(ChatEntity(role: .user, text: "Long User Message that spans over two lines!"))
            PlainMessageView(ChatEntity(role: .assistant(.response), text: "Long Assistant Message that spans over two lines!"))
            PlainMessageView(ChatEntity(role: .assistant(.toolCall), text: "assistent_too_call(parameter: value)"))
            PlainMessageView(ChatEntity(role: .assistant(.toolResponse), text: """
            {
                "some": "response"
            }
            """))
            PlainMessageView(ChatEntity(role: .hidden(type: .unknown), text: "Hidden message! (invisible)"))
            PlainMessageView(
                ChatEntity(
                    role: .hidden(type: .unknown),
                    text: "Hidden message! (visible)"
                )
            )
        }
        .padding()
    }
}
#endif
