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
        case assistant
        case assistantToolCall
        case assistantToolResponse
        case hidden(type: ChatEntity.HiddenMessageType)
        
        var rawValue: String {
            switch self {
            case .user: "user"
            case .assistant: "assistant"
            case .assistantToolCall: "assistant_tool_call"
            case .assistantToolResponse: "assistant_tool_response"
            case .hidden(let type): "hidden_\(type.name)"
            }
        }
    }
    
    public enum Content: Hashable, Sendable {
        public enum Image: Hashable, Sendable {
            case image(PlatformImage)
            case url(URL)
        }
        case text(String)
        // TODO how do we want this represented? the image directly? a URL? smth else entirely?
        case image(Image)
        
        /// The content's text, if applicable
        public var text: String? {
            switch self {
            case .text(let text):
                text
            case .image:
                nil
            }
        }
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
    
    /// Creates a `ChatEntity` with image content.
    ///
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `String`-based content of the ``ChatEntity``. Can contain Markdown-formatted text.
    ///    - complete: Indicates if the content of the ``ChatEntity`` is complete and will not receive any additional content. Defaults to `true`.
    ///    - id: Unique identifier of the ``ChatEntity``, defaults to a randomly assigned id.
    ///    - date: Timestamp on when the ``ChatEntity`` was originally created, defaults to the current time.
    public init(
        role: Role,
        image: PlatformImage,
        complete: Bool = true,
        id: UUID = UUID(),
        date: Date = .now
    ) {
        self.role = role
        self.content = .image(.image(image))
        self.complete = complete
        self.id = id
        self.date = date
    }
}


extension ChatEntity.Content: Codable {
    private enum CodingKeys: CodingKey {
        case text, image
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .text) {
            self = .text(text)
        } else if let image = try? container.decode(Image.self, forKey: .image) {
            self = .image(image)
        } else {
            throw DecodingError.keyNotFound(CodingKeys.text, .init(codingPath: [], debugDescription: "Found neither a text nor an image."))
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        case .image(let image):
            try container.encode(image, forKey: .image)
        }
    }
}


extension ChatEntity.Content.Image: Codable {
    private enum CodingKeys: CodingKey, CaseIterable {
        case data, url
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let url = try? container.decode(URL.self, forKey: .url) {
            self = .url(url)
        } else if let data = try? container.decode(Data.self, forKey: .data) {
            guard let image = PlatformImage(data: data) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .data,
                    in: container,
                    debugDescription: "Unable to decode image data into '\(PlatformImage.self)'"
                )
//                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unable to decode image data into '\(PlatformImage.self)'"))
            }
            self = .image(image)
        } else {
            throw DecodingError.keyNotFound(
                ChatEntity.Content.CodingKeys.image,
                .init(
                    codingPath: [],
                    debugDescription: "Expected either of \(CodingKeys.allCases.map { "'\($0)'" }.joined(separator: ", "))"
                )
            )
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .url(let url):
            try container.encode(url, forKey: .url)
        case .image(let image):
            guard let pngData = image.pngData() else {
                throw EncodingError.invalidValue(image, .init(codingPath: [], debugDescription: "Unable to obtain PNG data"))
            }
            try container.encode(pngData, forKey: .data)
        }
    }
}
