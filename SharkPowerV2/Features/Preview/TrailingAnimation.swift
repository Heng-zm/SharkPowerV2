//
//  TrailingAnimation.swift
//  SharkPowerV2
//
//  Continuous automotive light pulse with brilliant leading head and exponential decay tail.
//

import Foundation
import CoreGraphics

public struct TrailingAnimation: LEDAnimation {
    private let tailLength: CGFloat = 0.55   // Long trailing gradient falloff
    private let headFeather: CGFloat = 0.03  // Crisp leading edge with subtle photon dispersion

    public init() {}

    public func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat {
        let totalCycle = 1.0 + tailLength
        let speedFactor = CGFloat(parameters.frequency)
        let headPos = CGFloat((time * Double(speedFactor)).truncatingRemainder(dividingBy: Double(totalCycle)))

        // Position is behind the head within the tail length
        if position <= headPos && position >= (headPos - tailLength) {
            let distanceBehindHead = headPos - position
            let normalizedDistance = distanceBehindHead / tailLength
            
            // Non-linear decay representing real optical acrylic light absorption
            let tailFactor = pow(1.0 - normalizedDistance, 2.2)

            // Soften the immediate leading edge
            var leadingFactor: CGFloat = 1.0
            if distanceBehindHead < headFeather {
                leadingFactor = distanceBehindHead / headFeather
            }

            return max(0.0, min(1.0, tailFactor * leadingFactor))
        }

        return 0.0
    }
}
