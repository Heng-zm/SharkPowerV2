//
//  StaticAnimation.swift
//  SharkPowerV2
//
//  Continuous solid automotive illumination across the full light bar.
//

import Foundation
import CoreGraphics

public struct StaticAnimation: LEDAnimation {
    public init() {}

    public func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat {
        // Uniform continuous intensity across entire strip
        return 1.0
    }
}
