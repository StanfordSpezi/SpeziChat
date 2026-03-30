//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI
import Textual


extension PlainMessageView {
    struct MarkdownView: View {
        let text: String
        
        var body: some View {
            StructuredText(markdown: text)
                .textual.inlineStyle(
                    InlineStyle.gitHub
                        .code(.monospaced, .fontScale(0.85), .backgroundColor(.clear))
                )
                .textual.structuredTextStyle(.gitHub)
        }
    }
}
