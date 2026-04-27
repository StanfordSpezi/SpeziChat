//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI
import Textual


struct AssistantThinking: View {
    @Environment(\.locale) private var locale
    
    private let message: ChatEntity
    @State private var isShowingSheet = false
    
    var body: some View {
        switch message.role {
        case let .assistant(.thinking(startDate, endDate)):
            Button {
                isShowingSheet = true
            } label: {
                content(startDate: startDate, endDate: endDate)
            }
            // TODO disable if no thoughts! (also, dismiss should thoughts become empty!)
            .foregroundStyle(.secondary)
            .sheet(isPresented: $isShowingSheet) {
                switch message.content {
                case .text(let text):
                    sheetContent(for: text)
                }
            }
            // NOTE: if, at some point in the future, the OpenAI API also live-exposes the thinking process for reasoning models,
            // we could display that here.
        default:
            EmptyView()
        }
    }
    
    init(_ message: ChatEntity) {
        self.message = message
    }
    
    @ViewBuilder
    private func content(startDate: Date?, endDate: Date?) -> some View {
        if message.complete {
            if let startDate, let endDate {
                let duration = Duration.seconds(endDate.timeIntervalSince(startDate))
                Text("Thought for \(format(duration))", bundle: .module)
            } else {
                EmptyView()
            }
        } else {
            HStack {
                Text("Thinking…", bundle: .module)
                if let startDate {
                    TimelineView(.periodic(from: startDate, by: 0.1)) { context in
                        let duration = Duration.seconds(context.date.timeIntervalSince(startDate))
                        Text(format(duration))
                            .monospacedDigit()
                    }
                }
            }
        }
    }
    
    private func sheetContent(for content: String) -> some View {
        NavigationStack {
            ScrollView {
                if !content.isEmpty {
                    PlainMessageView.MarkdownView(text: content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                } else {
                    VStack {
                        Spacer()
                        Text("Still Thinking…", bundle: .module)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle(LocalizedStringResource("Model Thoughts", bundle: .module))
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    DismissButton()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func format(_ duration: Duration) -> LocalizedStringResource {
        let totalSecs = duration.timeInterval
        let mins = Int(totalSecs / 60)
        let secs = totalSecs.truncatingRemainder(dividingBy: 60)
        let secsFormatStyle = FloatingPointFormatStyle<TimeInterval>.number.precision(.fractionLength(1...2)).locale(locale)
        return if mins == 0 {
            LocalizedStringResource("\(secs, format: secsFormatStyle) sec", bundle: .module)
        } else {
            LocalizedStringResource("\(mins):\(secs, format: secsFormatStyle) min", bundle: .module)
        }
    }
}
