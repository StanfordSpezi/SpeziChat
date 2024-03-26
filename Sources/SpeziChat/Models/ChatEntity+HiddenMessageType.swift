//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension ChatEntity {
    /// The type of the ``Role-swift.enum/hidden(type:)`` message.
    ///
    /// ### Usage
    ///
    /// The ``ChatEntity/HiddenMessageType`` can be easily extended with new message types, even in different SPM targets or modules, via an extension, like:
    /// ```swift
    /// extension ChatEntity.HiddenMessageType {
    ///     static let testType = HiddenMessageType(name: "testType")
    /// }
    /// ```
    public struct HiddenMessageType: Codable, Equatable, Hashable {
        /// Default ``HiddenMessageType``.
        public static let unknown = HiddenMessageType(name: "unknown")
        
        
        /// The name of the type of the ``HiddenMessageType``.
        public let name: String
        
        
        /// Initializer of the ``ChatEntity/HiddenMessageType``
        /// - Parameters:
        ///     - name: The name of the hidden message type
        public init(name: String) {
            self.name = name
        }
    }
}
