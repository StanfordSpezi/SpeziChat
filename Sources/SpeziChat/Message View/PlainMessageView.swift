//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI
import Textual


private let maxMessageHeight: Double = 300


/// A reusable SwiftUI `View` to display the contents of a ``ChatEntity`` within a typical chat message bubble. This bubble is properly aligned according to the associated ``ChatEntity/Role``.
///
/// Messages with the ``ChatEntity/Role/hidden(type:)`` are hidden. These ``ChatEntity/Role``s are configurable via a parameter in the ``MessageView/init(_:hideMessages:)``.
///
/// ### Usage
///
/// ```swift
/// struct MessageViewTestView: View {
///     var body: some View {
///         VStack {
///             MessageView(ChatEntity(role: .user, content: "User Message!"))
///             MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
///             MessageView(ChatEntity(role: .hidden(type: .unknown), content: "System Message (hidden)!"))
///         }
///             .padding()
///     }
/// }
/// ```
struct PlainMessageView: View { // TODO rename MessageContentsView? or smth like that?
//    /// The minimum inset the message must have from the "opposing" edge, based on its alignment
//    private static let minHorizontalOpposingEdgeInset: Double = 32
    
    @Environment(\.chatMessageTruncationLimit)
    private var truncationLineLimit
    
    private let message: ChatEntity
    
    public var body: some View {
        Group {
            switch message.content {
            case .text(let text):
                TextMessageView(text: text)
//                    .frame(maxHeight: maxMessageHeight)
            case .image(let image):
                ImageView(image: image)
//                    .frame(maxHeight: maxMessageHeight)
            }
        }
        .clipped()
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
}


extension PlainMessageView {
    private struct TextMessageView: View {
        let text: String
        
        private let collapsedHeight: CGFloat = maxMessageHeight
        @State private var needsTruncation = false
        
        @State private var showSheet = false
        
        var body: some View {
//            ViewThatFits(in: .vertical) {
                fullMessageView
//                truncatedMessageView
//            }
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    fullMessageView
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                DismissButton()
                            }
                        }
                }
            }
        }
        
        private var fullMessageView: some View {
            markdownView(for: text)
        }
        
        private var truncatedMessageView: some View {
            VStack(alignment: .leading) {
                let text = text
                    .split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
//                    .prefix(50)
                    .joined(separator: "\n")
                markdownView(for: text)
//                    .background(.red)
                    .mask {
                        if !needsTruncation {
                            Rectangle()
                        } else {
                            VStack(spacing: 0) {
                                Rectangle()
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 40)
                            }
                        }
                    }
                    .background {
                        markdownView(for: text)
                            .chatMessageStyle(alignment: .leading)
                            .hidden()
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { height in
                                needsTruncation = height > collapsedHeight
                            }
                    }
                Divider()
                Button {
                    showSheet = true
                } label: {
                    HStack {
                        Text("Show More")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .accessibilityHidden(true)
                    }
                }
            }
            .frame(maxHeight: collapsedHeight, alignment: .top)
        }
        
        private func markdownView(for text: String) -> some View {
//            StructuredText(markdown: text)
//                .textual.structuredTextStyle(.gitHub)
//                .textual.inlineStyle(.default)
            PlainMessageView.MarkdownView(text: text)
        }
    }
    
    private struct ImageView: View {
        let image: ChatEntity.Content.Image
        
        var body: some View {
            switch image {
            case .image(let image):
                Image(platformImage: image)
            case .url(let url):
                AsyncImage(url: url)
            }
            // TODO sizing etc!!!
        }
    }
}


extension EnvironmentValues {
    @Entry fileprivate var chatMessageTruncationLimit: Int? = nil
}

extension View {
    public func chatMessageTruncationLimit(_ limit: Int?) -> some View {
        self.environment(\.chatMessageTruncationLimit, limit)
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
                ),
//                hideMessages: .custom(hiddenMessageTypes: [])
            )
        }
        .padding()
    }
}
#endif
