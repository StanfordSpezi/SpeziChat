//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension ChatView {
    /// Provides an iOS-typical Share Sheet (also called Activity View: https://developer.apple.com/design/human-interface-guidelines/activity-views) SwiftUI wrapper 
    /// for exporting the ``Chat`` content of the ``ChatView`` without the downsides of the SwiftUI `ShareLink` such as unnecessary reevaluations of the to-be shared content.
    struct ShareSheet: UIViewControllerRepresentable {
        let sharedItem: Data
        let sharedItemType: ChatExportFormat

        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            // Note: Need to write down the data to storage as in-memory shared content is not recognized properly (e.g., PDFs)
            var temporaryPath = FileManager.default.temporaryDirectory.appendingPathComponent("Exported Chat")
            
            switch sharedItemType {
            case .json: temporaryPath = temporaryPath.appendingPathExtension("json")
            case .text: temporaryPath = temporaryPath.appendingPathExtension("txt")
            case .pdf: temporaryPath = temporaryPath.appendingPathExtension("pdf")
            }
            
            try? sharedItem.write(to: temporaryPath)
            
            let controller = UIActivityViewController(
                activityItems: [temporaryPath],
                applicationActivities: nil
            )
            controller.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: temporaryPath)
            }
            
            return controller
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
