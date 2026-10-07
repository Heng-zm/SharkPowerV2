//
//  ReverseAnimation.swift
//  SharkPowerV2
//
//  Continuous sequential light bar sliding smoothly from right to left.
//

import Foundation
import CoreGraphics

public struct ReverseAnimation: LEDAnimation {
    private let forwardAnimation = ForwardAnimation()

    public init() {}

    public func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat {
        // Mirrored position for seamless right-to-left continuous travel
        let invertedPosition = 1.0 - position
        return forwardAnimation.intensity(at: invertedPosition, time: time, parameters: parameters)
    }
}
