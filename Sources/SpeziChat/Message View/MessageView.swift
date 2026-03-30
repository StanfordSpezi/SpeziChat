//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SpeziViews
import SwiftUI


/// Displays a ``ChatEntity``, selecting the correct style based on its ``ChatEntity/role``.
struct MessageView: View {
    /// The minimum inset the message must have from the "opposing" edge, based on its alignment
    private static let minHorizontalOpposingEdgeInset: Double = 32
    
    private let message: ChatEntity
    
    var body: some View {
        HStack {
            if message.alignment == .trailing {
                Spacer(minLength: Self.minHorizontalOpposingEdgeInset)
            }
            VStack(alignment: message.horziontalAlignment) {
                switch message.role {
                case .user:
                    UserMessageView(message)
                case .assistant, .hidden:
                    AssistantMessageView(message)
                case .assistantToolCall, .assistantToolResponse:
                    ToolInteractionView(entity: message)
                }
            }
            if message.alignment == .leading {
                Spacer(minLength: Self.minHorizontalOpposingEdgeInset)
            }
        }
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
}


/// Displays a user message.
private struct UserMessageView: View {
    private let message: ChatEntity
    
    var body: some View {
        PlainMessageView(message)
            .chatMessageStyle(alignment: .trailing)
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
}


/// Displays an assistant-generated message.
private struct AssistantMessageView: View {
    private let message: ChatEntity
    
    @State private var shareSheetInput: ShareSheetInput?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PlainMessageView(message)
            actions
        }
        .padding(.bottom)
    }
    
    private var actions: some View {
        HStack {
            makeAction("Copy", symbolName: "document.on.document") {
                switch message.content {
                case .text(let text):
                    UIPasteboard.general.string = text
                case .image:
                    // TODO!
                    break
                }
            }
            makeAction("Share", symbolName: "square.and.arrow.up") {
                switch message.content {
                case .text(let text):
                    shareSheetInput = .init(text)
                case .image(let image):
                    switch image {
                    case .image(let image):
                        shareSheetInput = .init(image)
                    case .url(let url):
                        shareSheetInput = .init(url)
                    }
                }
            }
            .shareSheet(item: $shareSheetInput)
            makeAction("Speak", symbolName: "speaker.wave.2") {
                // TODO speak!
            }
        }
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
    
    private func makeAction(
        _ title: LocalizedStringResource,
        symbolName: String,
        _ action: @escaping @MainActor () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Label(title, systemImage: symbolName)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
    }
}
