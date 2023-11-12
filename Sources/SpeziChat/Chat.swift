//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Observation
import Spezi


/// Spezi module to handle and display user interfaces for chat-based interactions.
///
/// > Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/setup) setup the core Spezi infrastructure.
/// 
/// The component needs to be registered in a Spezi-based application using the [`configuration`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate/configuration)
/// in a [`SpeziAppDelegate`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate):
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration {
///             Chat()
///             // ...
///         }
///     }
/// }
/// ```
/// > Tip: You can learn more about a [`Component` in the Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/component).
///
///
/// ## Usage
///
/// ...
/// ```swift
/// ...
/// ```
@Observable
public class Chat: Module, DefaultInitializable {
    /// Creates an instance of a ``Chat`` component.
    public required init() { }
}
