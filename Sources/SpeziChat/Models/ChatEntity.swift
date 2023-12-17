//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Represents the basic building block of a Spezi ``Chat``.
/// It consists of a ``ChatEntity/Role`` property as well as a `String`-based content property.
public struct ChatEntity: Codable, Equatable, Hashable {
    /// Indicates which ``ChatEntity/Role`` is associated with a ``ChatEntity``.
    public enum Role: String, Codable, Equatable {
        case system
        case assistant
        case user
        case function
    }
    
    /// Indicates if a ``ChatEntity`` is displayed in a leading or trailing position within a SwiftUI `View`.
    enum Alignment {
        case leading
        case trailing
    }
    
    
    /// ``ChatEntity/Role`` associated with the ``ChatEntity``.
    public let role: Role
    /// `String`-based content of the ``ChatEntity``.
    public let content: String
    /// The creation date of the ``ChatEntity``.
    public let date: Date
    
    
    /// Dependent on the ``ChatEntity/Role``, display a ``ChatEntity`` in a leading or trailing position.
    var alignment: Alignment {
        switch self.role {
        case .user:
            return .trailing
        default:
            return .leading
        }
    }
    
    
    /// Creates a ``ChatEntity`` which is the building block of a Spezi ``Chat``.
    /// - Parameters:
    ///    - role: ``ChatEntity/Role`` associated with the ``ChatEntity``.
    ///    - content: `String`-based content of the ``ChatEntity``.
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
        self.date = Date()
    }
}
