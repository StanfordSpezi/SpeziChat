//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation


/// Represents the basic building block of a Spezi ``Chat``.
///
/// A ``ChatEntity`` can be thought of as a single message entity within a ``Chat``
/// It consists of a ``ChatEntity/Role``, a unique identifier, a timestamp in the form of a `Date` as well as an `String`-based ``ChatEntity/content`` property which can contain Markdown-formatted text.
/// Furthermore, the ``ChatEntity/complete`` flag indicates if the current state of the ``ChatEntity`` is final and the content will not be updated anymore.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(role:text:complete:id:date:)``
/// - ``init(role:image:complete:id:date:)``
/// - ``init(role:content:complete:id:date:)``
public struct ChatEntity: Hashable, Identifiable, Codable, Sendable {
    /// Indicates which ``ChatEntity/Role`` is associated with a ``ChatEntity``.
    public enum Role: Hashable, Codable, Sendable {
        case user
        case assistant(AssistantMessageKind)
        case hidden(type: ChatEntity.HiddenMessageType)
        
        public enum AssistantMessageKind: Hashable, Codable, Sendable {
            case response
            case toolCall
            case toolResponse
        }
        
        @available(*, deprecated, message: "use .assistant(.response) instead!")
        public static var assistant: Self {
            .assistant(.response)
        }
        @available(*, deprecated, message: "use .assistant(.toolCall) instead!")
        public static var assistantToolCall: Self {
            .assistant(.toolCall)
        }
        @available(*, deprecated, message: "use .assistant(.toolResponse) instead!")
        public static var assistantToolResponse: Self {
            .assistant(.toolResponse)
        }
        
        var rawValue: String {
            switch self {
            case .user:
                "user"
            case .assistant(.response):
                "assistant"
            case .assistant(.toolCall):
                "assistant_tool_call"
            case .assistant(.toolResponse):
                "assistant_tool_response"
            case .hidden(let type):
                "hidden_\(type.name)"
            }
        }
    }
    
    public enum Content: Hashable, Sendable {
        case text(String)
    }
    
    
    /// ``ChatEntity/Role`` associated with the ``ChatEntity``.
    public let role: Role
    /// Content of the ``ChatEntity``.
    public let content: Content
    /// Indicates if the ``ChatEntity`` is complete and will not receive any additional content.
    public let complete: Bool
    /// Unique identifier of the ``ChatEntity``.
    public let id: UUID
    /// The creation date of the ``ChatEntity``.
    public let date: Date
    
    /// Creates a ``ChatEntity`` which is the building block of a Spezi ``Chat``.
    ///
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: content of the ``ChatEntity``.
    ///    - complete: Indicates if the content of the ``ChatEntity`` is complete and will not receive any additional content. Defaults to `true`.
    ///    - id: Unique identifier of the ``ChatEntity``, defaults to a randomly assigned id.
    ///    - date: Timestamp on when the ``ChatEntity`` was originally created, defaults to the current time.
    public init(
        role: Role,
        content: Content,
        complete: Bool = true,
        id: UUID = .init(),
        date: Date = .now
    ) {
        self.role = role
        self.content = content
        self.complete = complete
        self.id = id
        self.date = date
    }
}


extension ChatEntity {
    /// Creates a `ChatEntity` with text content.
    ///
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `String`-based content of the ``ChatEntity``. Can contain Markdown-formatted text.
    ///    - complete: Indicates if the content of the ``ChatEntity`` is complete and will not receive any additional content. Defaults to `true`.
    ///    - id: Unique identifier of the ``ChatEntity``, defaults to a randomly assigned id.
    ///    - date: Timestamp on when the ``ChatEntity`` was originally created, defaults to the current time.
    public init(
        role: Role,
        text: some StringProtocol,
        complete: Bool = true,
        id: UUID = UUID(),
        date: Date = .now
    ) {
        self.role = role
        self.content = .text(String(text))
        self.complete = complete
        self.id = id
        self.date = date
    }
}


extension ChatEntity.Content: Codable {
    private enum CodingKeys: CodingKey {
        case text
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .text) {
            self = .text(text)
        } else {
            throw DecodingError.keyNotFound(CodingKeys.text, .init(codingPath: [], debugDescription: "Unable to decode \(Self.self)"))
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        }
    }
}
