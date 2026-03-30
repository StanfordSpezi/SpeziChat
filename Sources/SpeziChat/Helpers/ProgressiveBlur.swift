//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(UIKit)

import SwiftUI


/// A View that applies a progressive blur to the content it is overlayed onto.
///
/// The blur is minimal at the top edge of the view, and maximal at the bottom edge.
struct ProgressiveBlur: UIViewRepresentable {
    private let style: UIBlurEffect.Style
    private let locations: [Double]
    
    init(style: UIBlurEffect.Style = .regular, locations: [Double] = [0, 1]) {
        self.style = style
        self.locations = locations
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        ProgressiveBlurUIView(style: style)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
        (uiView as? ProgressiveBlurUIView)?.locations = locations // will never be nil
    }
}


extension ProgressiveBlur {
    private final class ProgressiveBlurUIView: UIVisualEffectView {
        private let gradient = CAGradientLayer()
        
        var locations: [Double] {
            get {
                (gradient.locations ?? []).map(\.doubleValue)
            } set {
                gradient.locations = newValue.map { NSNumber(value: $0) }
            }
        }
        
        init(style: UIBlurEffect.Style) {
            super.init(effect: UIBlurEffect(style: style))
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            layer.mask = gradient
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradient.frame = bounds
        }
    }
}

#endif
