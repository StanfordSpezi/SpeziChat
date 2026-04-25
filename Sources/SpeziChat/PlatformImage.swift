//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order missing_docs

public import SwiftUI


#if canImport(UIKit)
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
public typealias PlatformImage = NSImage
#else
#error("Unsupported Platform")
#endif


extension Image {
    init(platformImage image: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        self.init(nsImage: image)
        #endif
    }
}


/// Common operations we want to have available across `UIImage` and `NSImage`.
public protocol _PlatformImageProtocol: AnyObject { // swiftlint:disable:this type_name
    init?(data: Data)
    init?(contentsOfFile: String)
    func pngData() -> Data?
}


#if canImport(UIKit)

extension UIImage: _PlatformImageProtocol {}

#elseif canImport(AppKit)

extension NSImage: _PlatformImageProtocol {
    public func pngData() -> Data? {
        guard let tiff = tiffRepresentation else {
            return nil
        }
        guard let bitmapRep = NSBitmapImageRep(data: tiff) else {
            return nil
        }
        return bitmapRep.representation(using: .png, properties: [:])
    }
}

#endif
