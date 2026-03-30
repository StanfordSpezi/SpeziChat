//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import os
import PDFKit
import SwiftUI


extension ChatView {
    /// Output format of the to-be exported ``Chat``.
    public enum ChatExportFormat {
        /// JSON representation of the ``Chat``
        case json
        /// Textual UTF-8 version of the ``Chat``
        case text
        /// Rendered PDF document of the ``Chat``
        case pdf
    }
    
    private static let logger = Logger(subsystem: "edu.stanford.spezi", category: "SpeziChat")
    private static let encoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }()
    

    /// Chat exported as `Data` in the format specified by ``ChatView/ChatExportFormat``
    @MainActor
    static func export(_ chat: Chat, as format: ChatExportFormat) -> Data? {
        switch format {
        case .json:
            exportToJson(chat)
        case .text:
            exportToText(chat)
        case .pdf:
            exportToPDF(chat)
        }
    }
    
    /// Exported chat encoded as JSON
    private static func exportToJson(_ chat: Chat) -> Data? {
        guard let jsonData = try? Self.encoder.encode(chat) else {
            Self.logger.error("The to be exported chat couldn't be encoded to JSON format!")
            return nil
        }
        return jsonData
    }
    
    /// Exported chat encoded as a textual UTF-8
    private static func exportToText(_ chat: Chat) -> Data? {
        let textData = chat.map {
            // Format: <ROLE> (<DATE>): <CONTENT>
            "\($0.role.rawValue.capitalized) (\($0.date.formatted())): \($0.content)"
        }
        .joined(separator: "\n")
        .data(using: .utf8)
        guard let textData else {
            Self.logger.error("The to be exported chat couldn't be encoded in a textual UTF-8 format!")
            return nil
        }
        return textData
    }
    
    /// Exported chat rendered as a PDF
    @MainActor
    private static func exportToPDF(_ chat: Chat) -> Data? {
        let renderer = ImageRenderer(content: PDFExportChatView(chat: chat))
        #if !os(macOS)
        var proposedHeightOptional = renderer.uiImage?.size.height
        #else
        var proposedHeightOptional = renderer.nsImage?.size.height
        #endif
        guard let proposedHeight = proposedHeightOptional else {
            Self.logger.error("""
            The to be exported chat couldn't be rendered as a PDF as the height of the rendered page couldn't be determined!
            """)
            return nil
        }
        // Width from US Letter, height requested by the view
        // Reason: Splitting a view in multiple PDF pages is complex!
        let size = CGSize(
            width: 72 * 8.5,    // US Letter width
            height: proposedHeight
        )
        renderer.proposedSize = .init(size)
        #if !os(macOS)
        proposedHeightOptional = renderer.uiImage?.size.height
        #else
        proposedHeightOptional = renderer.nsImage?.size.height
        #endif
        // Need to fetch page height again as it is adjusted after setting the `proposedSize` on the `ImageRenderer`
        guard let proposedHeight = proposedHeightOptional else {
            Self.logger.error("""
            The to be exported chat couldn't be rendered as a PDF as the height of the rendered page couldn't be determined!
            """)
            return nil
        }
        var pdfData: Data?
        renderer.render { _, context in
            var box = CGRect(
                origin: .zero,
                size: .init(width: size.width, height: proposedHeight)
            )
            guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                  let consumer = CGDataConsumer(data: mutableData),
                  let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                Self.logger.error("The to be exported chat couldn't be rendered as a PDF!")
                pdfData = nil
                return
            }
            pdf.beginPDFPage(nil)
            pdf.translateBy(x: 0, y: 0)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            pdfData = PDFDocument(data: mutableData as Data)?.dataRepresentation()
        }
        return pdfData
    }
}


/// As the ``ChatView`` and the ``MessagesView`` include elements that are not supported by the SwiftUI `ImageRenderer`,
/// the `ChatExportPDFView` serves as a simplified intermediary layer for the export of the ``Chat`` to a PDF.
private struct PDFExportChatView: View {
    let chat: Chat
    
    var body: some View {
        // The SwiftUI `ImageRenderer` doesn't support SwiftUI `List`s
        VStack(spacing: 8) {
            ForEach(chat, id: \.self) { chatEntity in
                PDFExportChatMessageView(message: chatEntity)
            }
            Spacer()
        }
        .padding()
    }
}


private struct PDFExportChatMessageView: View {
    let message: ChatEntity
    
    var body: some View {
        HStack {
            if message.alignment == .trailing {
                Spacer(minLength: 32)
            }
            VStack(alignment: message.alignment == .leading ? .leading : .trailing) {
                switch message.content {
                case .text(let text):
                    contentView(for: text)
                case .image(let image):
                    contentView(for: image)
                }
                switch message.role {
                case .hidden(let type):
                    Text("\(type.name.capitalized) (hidden): \(message.date.formatted())")
                        .font(.caption)
                        .foregroundColor(.gray)
                case .user, .assistant, .assistantToolCall, .assistantToolResponse:
                    Text("\(message.role.rawValue.capitalized): \(message.date.formatted())")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            if message.alignment == .leading {
                Spacer(minLength: 32)
            }
        }
    }
    
    @ViewBuilder
    private func contentView(for text: String) -> some View {
        // NOTE: we intentionally use a `Text` with an `AttributedString` here, instead of using `StructuredText` like in the MessageView,
        // the reason being that the `StructuredText` doesn't render properly during the PDF export.
        let attrString = { () -> AttributedString in
            let markdownOptions = AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
            return (try? AttributedString(markdown: text, options: markdownOptions)) ?? AttributedString(stringLiteral: text)
        }()
        Text(attrString)
            .fixedSize(horizontal: false, vertical: true)
            #if !os(visionOS)
            .chatMessageStyle(alignment: message.alignment)
            #else
            // Workaround setting the user background color to blue
            // for visionOS as .accentColor isn't properly set during export with the `ImageRenderer`
            .chatMessageStyle(alignment: message.alignment, backgroundColorUserChat: .blue)
            #endif
    }
    
    @ViewBuilder
    private func contentView(for image: ChatEntity.Content.Image) -> some View {
        switch image {
        case .image(let image):
            Image(platformImage: image)
                .accessibilityHidden(true)
        case .url(let url):
            AsyncImage(url: url)
        }
        // TODO size/etc!!!
    }
}
