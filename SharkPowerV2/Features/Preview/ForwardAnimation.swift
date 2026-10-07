//
//  ForwardAnimation.swift
//  SharkPowerV2
//
//  Continuous sequential light bar sliding smoothly from left to right.
//

import Foundation
import CoreGraphics

public struct ForwardAnimation: LEDAnimation {
    private let segmentLength: CGFloat = 0.35  // Length of sliding beam relative to strip
    private let edgeFeather: CGFloat = 0.05    // Soft edge transition for organic light dispersion

    public init() {}

    public func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat {
        let totalCycleDistance = 1.0 + segmentLength
        let speedFactor = CGFloat(parameters.frequency)
        let rawProgress = CGFloat((time * Double(speedFactor)).truncatingRemainder(dividingBy: Double(totalCycleDistance)))
        
        let beamHead = rawProgress
        let beamTail = beamHead - segmentLength

        // Check if position lies within the sliding beam
        if position >= beamTail && position <= beamHead {
            var intensity: CGFloat = 1.0

            // Soft front edge
            if position > beamHead - edgeFeather {
                let dist = beamHead - position
                intensity = min(intensity, dist / edgeFeather)
            }
            // Soft rear edge
            if position < beamTail + edgeFeather {
                let dist = position - beamTail
                intensity = min(intensity, dist / edgeFeather)
            }

            return max(0.0, min(1.0, intensity))
        }

        return 0.0
    }
}
