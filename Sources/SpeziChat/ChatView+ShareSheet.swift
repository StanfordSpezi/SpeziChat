//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#endif


extension ChatView {
    /// Provides an iOS-typical Share Sheet (also called Activity View: https://developer.apple.com/design/human-interface-guidelines/activity-views) SwiftUI wrapper
    /// for exporting the ``Chat`` content of the ``ChatView`` without the downsides of the SwiftUI `ShareLink` such as unnecessary reevaluations of the to-be shared content.
    #if !os(macOS)
    struct ShareSheet: UIViewControllerRepresentable {
        let sharedItem: Data
        let sharedItemType: ChatExportFormat

        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            // Note: Need to write down the data to storage as in-memory shared content is not recognized properly (e.g., PDFs)
            let temporaryPath = temporaryExportFilePath(sharedItemType: sharedItemType)
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
    #else
    @MainActor
    struct ShareSheet {
        let sharedItem: Data
        let sharedItemType: ChatExportFormat
        

        func show() {
            // Note: Need to write down the data to storage as in-memory shared content is not recognized properly (e.g., PDFs)
            let temporaryPath = temporaryExportFilePath(sharedItemType: sharedItemType)
            try? sharedItem.write(to: temporaryPath)

            let sharingServicePicker = NSSharingServicePicker(items: [temporaryPath])

            // Present the sharing service picker
            if let keyWindow = NSApp.keyWindow, let contentView = keyWindow.contentView {
                sharingServicePicker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
            }
        }
    }
    #endif
    
    
    /// Constructs the temporary file path for the exported chat file.
    ///
    /// - Parameters:
    ///    - sharedItemType: The shared item type, therefore defining the file extension.
    static func temporaryExportFilePath(sharedItemType: ChatExportFormat) -> URL {
        var temporaryPath = FileManager.default.temporaryDirectory.appendingPathComponent("Exported Chat")
        
        switch sharedItemType {
        case .json: temporaryPath = temporaryPath.appendingPathExtension("json")
        case .text: temporaryPath = temporaryPath.appendingPathExtension("txt")
        case .pdf: temporaryPath = temporaryPath.appendingPathExtension("pdf")
        }
        
        return temporaryPath
    }
}
