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

### 1. Add Spezi Chat as a Dependency

You need to add the Spezi Chat Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to setup the core Spezi infrastructure.

### 2. Configure target properties

As ``SpeziChat`` is utilizing the [SpeziSpeech](https://github.com/StanfordSpezi/SpeziSpeech) module under the hood for speech interaction capabilities, one needs to ensure that your application has the necessary permissions for microphone access and speech recognition. Follow the steps below to configure the target properties within your Xcode project:

- Open your project settings in Xcode by selecting *PROJECT_NAME > TARGET_NAME > Info* tab.
- You will need to add two entries to the `Custom iOS Target Properties` (so the `Info.plist` file) to provide descriptions for why your app requires these permissions:
   - Add a key named `Privacy - Microphone Usage Description` and provide a string value that describes why your application needs access to the microphone. This description will be displayed to the user when the app first requests microphone access.
   - Add another key named `Privacy - Speech Recognition Usage Description` with a string value that explains why your app requires the speech recognition capability. This will be presented to the user when the app first attempts to perform speech recognition.

These entries are mandatory for apps that utilize microphone and speech recognition features. Failing to provide them will result in your app being unable to access these features. 

## Usage

The underlying data model of ``SpeziChat`` is a ``Chat``. It represents the content of a typical text-based chat between user and system(s). A ``Chat`` is nothing more than an ordered array of ``ChatEntity``s which contain the content of the individual messages.
A ``ChatEntity`` consists of a ``ChatEntity/Role-swift.enum``, a timestamp as well as an `String`-based content which can contain Markdown-formatted text. In addition, a flag indicates if the `ChatEntity` is complete and no further content will be added.

> Tip: The ``ChatEntity`` is able to store Markdown-based content which in turn is rendered as styled text in the ``ChatView``, ``MessagesView``, and ``MessageView``.

### Chat View

The ``ChatView`` provides a basic reusable chat view which includes a message input field. The input can be either typed out via the iOS keyboard or provided as voice input and transcribed into written text. It accepts an additional `messagePendingAnimation` parameter to control whether a chat bubble animation is shown for a message that is currently being composed. By default, `messagePendingAnimation` has a value of `nil` and does not show.
In addition, the ``ChatView`` provides functionality to export the visualized ``Chat`` as a PDF document, JSON representation, or textual UTF-8 file (see ``ChatView/ChatExportFormat``) via a Share Sheet (or Activity View).

```swift
struct ChatTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .assistant, content: "Assistant Message!")
    ]

    
    var body: some View {
        ChatView($chat, exportFormat: .pdf)
            .navigationTitle("SpeziChat")
    }
}
```

- Tip: The ``ChatView`` provides speech-to-text (recognition) as well as text-to-speech (synthesize) accessibility capabilities out-of-the-box via the [`SpeziSpeech`](https://github.com/StanfordSpezi/SpeziSpeech) module, facilitating seamless interaction with the content of the ``ChatView``.

### Messages View

The ``MessagesView`` displays a ``Chat`` containing multiple ``ChatEntity``s with different ``ChatEntity/Role``s in a typical chat-like fashion.
The `View` automatically scrolls down to the newest message that is added to the passed ``Chat`` SwiftUI `Binding`.
The `typingIndicator` parameter controls when a typing indicator is shown onscreen for incoming messages to `Chat`.

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
            MessageView(ChatEntity(role: .hidden(type: .unknown), content: "System Message (hidden)!"))
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
    
    
    var body: some View {
        VStack {
            Spacer()
            MessageInputView($chat, messagePlaceholder: "TestMessage")
                .disabled(disableInput)
                /// Get the height of the `MessageInputView` via a SwiftUI `PreferenceKey`
                /// Indicates the height of the input message field, necessary for properly shifting other view content.
                .onPreferenceChange(MessageInputViewHeightKey.self) { newValue in
                    let messageInputHeight: CGFloat = newValue
                    // ...
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

### Message models

- ``Chat``
- ``ChatEntity``
- ``ChatEntity/Role-swift.enum``
- ``ChatEntity/HiddenMessageType``

### User input

- ``MessageInputView``
- ``MessageInputViewHeightKey``
