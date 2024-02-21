//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Represents the basic building block of a Spezi ``Chat``.
///
/// A ``ChatEntity`` can be thought of as a single message entity within a ``Chat``
/// It consists of a ``ChatEntity/Role``, a timestamp in the form of a `Date` as well as an `String`-based ``ChatEntity/content`` property which can contain Markdown-formatted text.
/// Furthermore, the ``ChatEntity/complete`` flag indicates if the current state of the ``ChatEntity`` is final and the content will not be updated anymore.
public struct ChatEntity: Codable, Equatable, Hashable {
    /// Indicates which ``ChatEntity/Role`` is associated with a ``ChatEntity``.
    public enum Role: Codable, Equatable, Hashable {
        case system
        case assistant
        case user
        case function(name: String)
        
        
        var rawValue: String {
            switch self {
            case .system: "system"
            case .assistant: "assistant"
            case .user: "user"
            case .function: "function"
            }
        }
    }
    
    
    /// ``ChatEntity/Role`` associated with the ``ChatEntity``.
    public let role: Role
    /// `String`-based content of the ``ChatEntity``.
    public let content: String
    /// The creation date of the ``ChatEntity``.
    public let date: Date
    /// Indicates if the ``ChatEntity`` is complete and will not receive any additional content.
    public let complete: Bool
    
    
    /// Markdown-formatted ``ChatEntity/content`` as an `AttributedString`, required to render the text in Markdown-style within the ``MessageView``.
    var attributedContent: AttributedString {
        let markdownOptions = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        )
        
        if let attributedContent = try? AttributedString(markdown: content, options: markdownOptions) {
            return attributedContent
        } else {
            return AttributedString(stringLiteral: content)
        }
    }

    
    /// Creates a ``ChatEntity`` which is the building block of a Spezi ``Chat``.
    ///
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `String`-based content of the ``ChatEntity``. Can contain Markdown-formatted text.
    ///    - complete: Indicates if the content of the ``ChatEntity`` is complete and will not receive any additional content. Defaults to `true`.
    public init<Content: StringProtocol>(role: Role, content: Content, complete: Bool = true) {
        self.role = role
        self.content = String(content)
        self.complete = complete
        self.date = Date()
    }
}
