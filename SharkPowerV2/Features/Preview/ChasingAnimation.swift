//
//  ChasingAnimation.swift
//  SharkPowerV2
//
//  Multiple continuous light segments traversing sequentially through the strip.
//

import Foundation
import CoreGraphics

public struct ChasingAnimation: LEDAnimation {
    private let segmentCount: Int = 3
    private let segmentWidth: CGFloat = 0.18
    private let edgeFeather: CGFloat = 0.04

    public init() {}

    public func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat {
        let speedFactor = CGFloat(parameters.frequency)
        let baseOffset = CGFloat((time * Double(speedFactor)).truncatingRemainder(dividingBy: 1.0))

        var maxIntensity: CGFloat = 0.0

        for i in 0..<segmentCount {
            let segmentSpacing = 1.0 / CGFloat(segmentCount)
            let center = (baseOffset + (CGFloat(i) * segmentSpacing)).truncatingRemainder(dividingBy: 1.0)
            
            // Distance on a torus [0.0, 1.0] for seamless wrapping
            var dist = abs(position - center)
            if dist > 0.5 {
                dist = 1.0 - dist
            }

            let halfWidth = segmentWidth / 2.0
            if dist <= halfWidth {
                var segIntensity: CGFloat = 1.0
                if dist > halfWidth - edgeFeather {
                    let edgeDist = halfWidth - dist
                    segIntensity = edgeDist / edgeFeather
                }
                maxIntensity = max(maxIntensity, segIntensity)
            }
        }

        return max(0.0, min(1.0, maxIntensity))
    }
}
