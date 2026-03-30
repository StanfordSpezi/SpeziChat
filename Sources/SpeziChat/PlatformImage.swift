//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


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


public protocol _PlatformImageProtocol: AnyObject {
    init?(data: Data)
    init?(contentsOfFile: String)
    func pngData() -> Data?
}

#if canImport(UIKit)
extension UIImage: _PlatformImageProtocol {}
#elseif canImport(AppKit)
extension NSImage: _PlatformImageProtocol {}
#endif
