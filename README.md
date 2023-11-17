<!--
                  
This source file is part of the Stanford Spezi open source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

# Spezi Chat

[![Build and Test](https://github.com/StanfordSpezi/SpeziChat/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziChat/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziChat/graph/badge.svg?token=b2Dn0r9eo6)](https://codecov.io/gh/StanfordSpezi/SpeziChat)


Provides UI components for building chat-based applications.


## Overview

The `SpeziChat` module provides views that can be used to implement chat-based use cases, such as a message view or a voice input field.

|![Screenshot displaying the regular chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView.png#gh-light-mode-only) ![Screenshot displaying the regular chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView~dark.png#gh-dark-mode-only)|![Screenshot displaying the text input chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView+TextInput.png#gh-light-mode-only) ![Screenshot displaying the text input chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView+TextInput~dark.png#gh-dark-mode-only)|![Screenshot displaying the voice input chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView+VoiceInput.png#gh-light-mode-only) ![Screenshot displaying the voice input chat view.](Sources/SpeziChat/SpeziChat.docc/Resources/ChatView+VoiceInput~dark.png#gh-dark-mode-only)
|:--:|:--:|:--:|
|[`ChatView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/chatview)|[`ChatView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/chatview)|[`ChatView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/chatview)|


## Setup


### Add Spezi Chat as a Dependency

You need to add the Spezi Chat Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]  
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to setup the core Spezi infrastructure.
   
## Examples

### Chat View

The [`ChatView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/chatview) provides a basic reusable chat view which includes a message input field. The input can be either typed out via the iOS keyboard or provided as voice input and transcribed into written text.

```swift
struct ChatTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .assistant, content: "Assistant Message!")
    ]


    var body: some View {
        ChatView($chat)
            .navigationTitle("SpeziChat")
    }
}
```

### Messages View

The [`MessagesView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/messagesview) displays a `Chat` containing multiple `ChatEntity`s with different `ChatEntity/Role`s in a typical chat-like fashion.
The `View` automatically scrolls down to the newest message that is added to the passed `Chat` SwiftUI `Binding`.

```swift
struct MessagesViewTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .user, content: "User Message!"),
        ChatEntity(role: .assistant, content: "Assistant Message!")
    ]


    var body: some View {
        MessagesView($chat)
    }
}
```

### Message View

The [`MessageView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/messageview) is a reusable SwiftUI `View` to display the contents of a `ChatEntity` within a typical chat message bubble. This bubble is properly aligned according to the associated `ChatEntity/Role`.

```swift
struct MessageViewTestView: View {
    var body: some View {
        VStack {
            MessageView(ChatEntity(role: .user, content: "User Message!"))
            MessageView(ChatEntity(role: .assistant, content: "Assistant Message!"))
            MessageView(ChatEntity(role: .system, content: "System Message (hidden)!"))
        }
            .padding()
    }
}
```

### MessageInput View

The [`MessageInputView`](https://swiftpackageindex.com/stanfordspezi/spezichat/documentation/spezichat/messageinputview) is a reusable SwiftUI `View` to handle text-based or speech-based user input. The provided message is attached to the passed `Chat` via a SwiftUI `Binding`.

```swift
struct MessageInputTestView: View {
    @State private var chat: Chat = []
    @State private var disableInput = false
    @State private var messageInputHeight: CGFloat = 0
    
    
    var body: some View {
        VStack {
            Spacer()
            MessageInputView($chat, messagePlaceholder: "TestMessage")
                .disabled(disableInput)
                /// Get the height of the `MessageInputView` via a SwiftUI `PreferenceKey`
                .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
                    messageInputHeight = newValue
                }
        }
    }
}
```

For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziChat/documentation).

## Applications using Spezi Chat

[HealthGPT](https://github.com/StanfordBDHG/HealthGPT) and [LLMonFHIR](https://github.com/StanfordBDHG/LLMonFHIR) provide a great starting points and examples using the `SpeziChat` module.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziChat/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
