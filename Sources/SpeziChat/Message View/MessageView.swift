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
                case .assistant(.response), .hidden:
                    AssistantMessageView(message)
                case .assistant(.thinking):
                    AssistantThinkingIndicator(message: message)
                case .assistant(.toolCall), .assistant(.toolResponse):
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
        HStack { // swiftlint:disable:this closure_body_length
            makeAction(LocalizedStringResource("Copy", bundle: .module), symbolName: "document.on.document") {
                message.content.copyToPasteboard()
            }
            makeAction(LocalizedStringResource("Share", bundle: .module), symbolName: "square.and.arrow.up") {
                switch message.content {
                case .text(let text):
                    shareSheetInput = .init(text)
                }
            }
            .shareSheet(item: $shareSheetInput)
            makeAction(LocalizedStringResource("Speak", bundle: .module), symbolName: "speaker.wave.2") {
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


private struct AssistantThinkingIndicator: View {
    private struct SheetContent: Identifiable {
        let id = UUID()
        let text: String
    }
    
    let message: ChatEntity
    
    @State private var thinkingTextSheetContent: SheetContent?
    
    var body: some View {
        switch message.role {
        case .assistant(.thinking(let startDate)):
            Button {
                switch message.content {
                case .text(let text):
                    thinkingTextSheetContent = text.isEmpty ? nil : .init(text: text)
                }
            } label: {
                Text("Thinking…", bundle: .module)
                    .foregroundStyle(message.complete ? .green : .red)
                if let startDate {
                    timer(withStartDate: startDate)
                }
            }
            .foregroundStyle(.secondary)
            .sheet(item: $thinkingTextSheetContent) { content in
                sheetContent(for: content)
            }
            // NOTE: if, at some point in the future, the OpenAI API also live-exposes the thinking process for reasoning models,
            // we could display that here.
        default:
            EmptyView()
        }
    }
    
    private func timer(withStartDate startDate: Date) -> some View {
        Text(timerInterval: startDate...(.distantFuture), pauseTime: nil, countsDown: false, showsHours: false)
    }
    
    private func sheetContent(for content: SheetContent) -> some View {
        NavigationStack {
            ScrollView {
                PlainMessageView.MarkdownView(text: content.text)
                    .padding(.horizontal)
            }
            .navigationTitle("Model Thoughts")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    DismissButton()
                }
            }
        }
        .presentationDetents([.medium])
    }
}
