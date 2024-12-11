//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The underlying `ViewModifier` of `View/speechToolbarButton(enabled:muted:)`.
private struct ChatViewSpeechButtonModifier: ViewModifier {
    @Binding var muted: Bool
    
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        muted.toggle()
                    }) {
                        if !muted {
                            Image(systemName: "speaker")
                                .accessibilityIdentifier("Speaker")
                                .accessibilityLabel(Text("Text to speech is enabled, press to disable text to speech.", bundle: .module))
                        } else {
                            Image(systemName: "speaker.slash")
                                .accessibilityIdentifier("Speaker strikethrough")
                                .accessibilityLabel(Text("Text to speech is disabled, press to enable text to speech.", bundle: .module))
                        }
                    }
                }
            }
    }
}


extension View {
    /// Adds a toolbar `Button` to mute or unmute text-to-speech capabilities.
    ///
    /// When attaching the ``speechToolbarButton(muted:)`` modifier to a `View` that resides within a SwiftUI `NavigationStack`,
    /// a `Button` is added to the toolbar that enables text-to-speech capabilities.
    /// The outside `View` is able to observe taps on that `Button` via passing in a SwiftUI `Binding` as the `muted` parameter, directly tracking the state of the `Button` but also being able to modify it from the outside.
    /// In addition, the button can be programatically hidden by adjusting the `enabled` parameter at any time.
    ///
    /// - Warning: Ensure that the ``ChatView`` resides within a SwiftUI `NavigationStack`, otherwise the added toolbar `Button` won't be shown.
    ///
    /// ### Usage
    ///
    /// The code snipped below demonstrates a minimal example of adding a text-to-speech toolbar button that mutes or unmutes text-to-speech output generation.
    ///
    /// ```swift
    /// struct ChatTestView: View {
    ///     @State private var chat: Chat = [
    ///         ChatEntity(role: .assistant, content: "**Assistant** Message!")
    ///     ]
    ///     @State private var muted = true
    ///
    ///     var body: some View {
    ///         ChatView($chat)
    ///             .speak(chat, muted: muted)
    ///             .speechToolbarButton(muted: $muted)
    ///             .task {
    ///                 // Add new completed `assistant` content to the `Chat` that is outputted via speech.
    ///                 // ...
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///    - muted: A SwiftUI `Binding` that indicates if the speech output is currently muted. The `Binding` enables the adjustment of the muted status by both the caller and the toolbar `Button`.
    public func speechToolbarButton(
        muted: Binding<Bool>
    ) -> some View {
        modifier(
            ChatViewSpeechButtonModifier(
                muted: muted
            )
        )
    }
}


#if DEBUG
#Preview {
    @Previewable @State var chat: Chat = .init(
        [
            ChatEntity(role: .user, content: "User Message!"),
            ChatEntity(role: .hidden(type: .unknown), content: "Hidden Message!"),
            ChatEntity(role: .assistant, content: "Assistant Message!")
        ]
    )
    @Previewable @State var muted = true
    
    
    return NavigationStack {
        ChatView($chat)
            .speak(chat, muted: muted)
            .speechToolbarButton(muted: $muted)
    }
}
#endif
