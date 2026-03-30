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
        case .image(let image):
            ImageView(image: image)
        }
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
}


extension PlainMessageView {
    private struct ImageView: View {
        let image: ChatEntity.Content.Image
        
        var body: some View {
            switch image {
            case .image(let image):
                Image(platformImage: image)
                    .accessibilityLabel("Image")
            case .url(let url):
                AsyncImage(url: url)
            }
            // TODO sizing etc!!!
        }
    }
    
    
    private struct MarkdownView: View {
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
            PlainMessageView(ChatEntity(role: .assistant, text: "Assistant Message!"))
            PlainMessageView(ChatEntity(role: .user, text: "Long User Message that spans over two lines!"))
            PlainMessageView(ChatEntity(role: .assistant, text: "Long Assistant Message that spans over two lines!"))
            PlainMessageView(ChatEntity(role: .assistantToolCall, text: "assistent_too_call(parameter: value)"))
            PlainMessageView(ChatEntity(role: .assistantToolResponse, text: """
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
