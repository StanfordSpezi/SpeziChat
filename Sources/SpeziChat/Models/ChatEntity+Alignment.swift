//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ChatEntity {
    /// Indicates if a ``ChatEntity`` is displayed in a leading or trailing position within a SwiftUI `View`.
    enum Alignment {
        case leading
        case trailing
    }
    
    
    /// Dependent on the ``ChatEntity/Role``, display a ``ChatEntity`` in a leading or trailing position.
    var alignment: Alignment {
        switch self.role {
        case .user, .function:
            return .trailing
        default:
            return .leading
        }
    }
}
