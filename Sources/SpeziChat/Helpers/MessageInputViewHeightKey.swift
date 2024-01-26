//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A SwiftUI `PreferenceKey` that is used by the ``MessageInputView`` to propagate the height of the view up the view hierarchy.
public struct MessageInputViewHeightKey: PreferenceKey {
    /// Default height of 0.
    public static var defaultValue: CGFloat = 0

    
    /// Writes the received value to the `PreferenceKey`.
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


/// View modifier to write the height of a `View` to the ``MessageInputViewHeightKey`` SwiftUI `PreferenceKey`.
extension View {
    func messageInputViewHeight(_ value: CGFloat) -> some View {
        self.preference(key: MessageInputViewHeightKey.self, value: value)
    }
}
