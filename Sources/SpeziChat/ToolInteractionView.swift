//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// The view that is represented when a tool call or tool reponse based on the ``ChatEntity/Role``.
struct ToolInteractionView: View {
    let entity: ChatEntity
    @State private var isExpanded: Bool = false
    
    var body: some View {
        switch entity.role {
        case .assistantToolCall:
            toolCallView(content: entity.content)
        case .assistantToolResponse:
            toolResponseView(content: entity.content)
        default:
            EmptyView()
        }
    }
    
    private func toolCallView(content: String) -> some View {
        HStack {
            Image(systemName: "function")
                .frame(width: 20)
            Text(content)
                .foregroundStyle(.secondary)
                .font(.footnote)
                .lineLimit(isExpanded ? nil : 0)
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private func toolResponseView(content: String) -> some View {
        HStack {
            Image(systemName: "equal")
                .frame(width: 20)
            
            Group {
                if content.contains(where: \.isNewline) && !isExpanded {
                    Text(String(localized: "SEE_MORE", bundle: .module))
                        .italic()
                } else {
                    Text(content)
                }
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
            .lineLimit(isExpanded ? nil : 0)
            
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    ToolInteractionView(entity: .init(role: .assistantToolCall, content: "foo(bar: baz) This is a very long text that should be truncated"))
    ToolInteractionView(entity: .init(role: .assistantToolResponse, content: """
    {
        "some": "response"
    }
    """))
}
