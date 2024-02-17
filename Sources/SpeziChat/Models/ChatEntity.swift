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
/// It consists of a ``ChatEntity/Role``, a timestamp in the form of a `Date` as well as an `AttributedString`-based content property,
/// providing traits like visual styles for display (e.g., Markdown), accessibility for guided access, and hyperlink data for linking between data sources.

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
    /// `AttributedString`-based content of the ``ChatEntity``.
    public let content: AttributedString
    /// The creation date of the ``ChatEntity``.
    public let date: Date
    
    
    /// Creates a ``ChatEntity`` which is the building block of a Spezi ``Chat``.
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `AttributedString`-based content of the ``ChatEntity``, enabling the persistence of Markdown content.
    public init(role: Role, content: AttributedString) {
        self.role = role
        self.content = content
        self.date = Date()
    }
    
    /// Creates a ``ChatEntity`` which is the building block of a Spezi ``Chat``.
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `String`-based content of the ``ChatEntity``, stored as a `String` literal.
    public init<Content: StringProtocol>(role: Role, content: Content) {
        self.role = role
        self.content = AttributedString(stringLiteral: String(content))
        self.date = Date()
    }
}
