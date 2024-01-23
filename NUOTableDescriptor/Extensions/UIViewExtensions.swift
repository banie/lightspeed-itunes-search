//
//  UIViewExtensions.swift
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

import Foundation
import UIKit

@objc public extension UIView {
    static func viewAnimationOptions(curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        var options: UIView.AnimationOptions = []
        switch curve {
        case .linear:
            options = .curveLinear
        case .easeIn:
            options = .curveEaseIn
        case .easeOut:
            options = .curveEaseOut
        case .easeInOut:
            options = .curveEaseInOut
        @unknown default:
            break
        }
        return options
    }
}
