//
//  LEDAnimationFactory.swift
//  SharkPowerV2
//
//  Central factory routing lighting modes to continuous optical animation strategies.
//  Strictly compliant with Section 9 Architecture:
//  LightingMode -> LEDAnimationFactory -> StaticAnimation / ForwardAnimation / ... -> LEDCanvasRenderer -> TimelineView
//

import SwiftUI

public final class LEDAnimationFactory {
    public static let shared = LEDAnimationFactory()

    private init() {}

    /// Creates and returns the continuous optical animation strategy for the specified lighting mode.
    ///
    /// - Parameter mode: The target LightingMode / LEDMode.
    /// - Returns: Concrete animation strategy conforming to `LEDAnimation`.
    public static func animation(for mode: LightingMode) -> LEDAnimation {
        switch mode {
        case .forward:
            return ForwardAnimation()
        case .reverse:
            return ReverseAnimation()
        case .trailing:
            return TrailingAnimation()
        case .chasing:
            return ChasingAnimation()
        case .staticGlow:
            return StaticAnimation()
        }
    }

    /// Instance method delegation for dependency injection or protocol conformance.
    public func createAnimation(for mode: LightingMode) -> LEDAnimation {
        Self.animation(for: mode)
    }
}
