# ``SpeziChat``

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Provides UI components for building chat-based applications.

## Overview

The ``SpeziChat`` module provides views that can be used to implement chat-based use cases, such as a message view or a voice input field.

@Row {
    @Column {
        @Image(source: "ChatView.png", alt: "Screenshot displaying the regular chat view.") { 
            A ``ChatView`` allows you to display a messages in a typical chat-like manner. 
        } 
    } 
    @Column { 
        @Image(source: "ChatView+TextInput.png", alt: "Screenshot displaying the text input chat view.") { 
            A ``ChatView`` enables the input of new messages via text. 
        } 
    } 
    @Column { 
        @Image(source: "ChatView+VoiceInput.png", alt: "Screenshot displaying the voice input chat view.") { 
            A ``ChatView`` allows users to use their voice for input (speech-to-text). 
        } 
    } 
}

## Setup

### Add Spezi Chat as a Dependency

You need to add the Spezi Chat Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to setup the core Spezi infrastructure.

## Examples

### Chat View

The ``ChatView`` provides a basic reusable chat view which includes a message input field. The input can be either typed out via the iOS keyboard or provided as voice input and transcribed into written text.

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

The ``MessagesView`` displays a ``Chat`` containing multiple ``ChatEntity``s with different ``ChatEntity/Role``s in a typical chat-like fashion.
The `View` automatically scrolls down to the newest message that is added to the passed ``Chat`` SwiftUI `Binding`.

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

The ``MessageView`` is a reusable SwiftUI `View` to display the contents of a ``ChatEntity`` within a typical chat message bubble. This bubble is properly aligned according to the associated ``ChatEntity/Role``.

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

The ``MessageInputView`` is a reusable SwiftUI `View` to handle text-based or speech-based user input. The provided message is attached to the passed ``Chat`` via a SwiftUI `Binding`.

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

## Topics

### Display messages

- ``ChatView``
- ``MessagesView``
- ``MessageView``

### User input

- ``MessageInputView``
- ``MessageInputViewHeightKey``

### Message models

- ``Chat``
- ``ChatEntity``
