//
//  LEDAnimation.swift
//  SharkPowerV2
//
//  Continuous LED animation engine protocol and parameter models.
//

import SwiftUI

public enum LightingMode: String, CaseIterable, Identifiable, Codable {
    case forward = "Forward"
    case reverse = "Reverse"
    case trailing = "Trailing"
    case chasing = "Chasing"
    case staticGlow = "Static"

    public var id: String { rawValue }

    public init?(rawValue: String) {
        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "forward": self = .forward
        case "reverse": self = .reverse
        case "trailing": self = .trailing
        case "chasing": self = .chasing
        case "static", "staticglow": self = .staticGlow
        default: return nil
        }
    }

    /// Original mode name as identified in SUPRE RACERS (com.sharkpower.supreracers)
    public var originalName: String {
        switch self {
        case .forward: return "Forward"
        case .reverse: return "Reverse"
        case .trailing: return "Trailing"
        case .chasing: return "Chasing"
        case .staticGlow: return "Static Glow"
        }
    }

    public var iconName: String {
        switch self {
        case .forward: return "arrow.right"
        case .reverse: return "arrow.left"
        case .trailing: return "sparkles"
        case .chasing: return "water.waves"
        case .staticGlow: return "sun.max.fill"
        }
    }

    public var description: String {
        switch self {
        case .forward: return "Sequential sliding beam flowing left to right"
        case .reverse: return "Sequential sliding beam flowing right to left"
        case .trailing: return "Intense leading edge with smooth gradient decay tail"
        case .chasing: return "Continuous dual light bars traversing in sync"
        case .staticGlow: return "Solid constant illumination across full light bar"
        }
    }

    public var discoveryStatus: String { "DISCOVERED" }
    public var implementationStatus: String { "IMPLEMENTED" }
    public var hardwareStatus: String { "TBD" }
}

/// Seamless backward-compatibility alias ensuring zero breaking changes across existing components.
public typealias LEDMode = LightingMode

public struct LEDAnimationParameters: Equatable {
    public var speed: Double       // Normalized 0.0 ... 1.0
    public var brightness: Double  // Normalized 0.0 ... 1.0
    public var color: Color
    public var reverse: Bool

    public init(
        speed: Double = 0.5,
        brightness: Double = 0.85,
        color: Color = SharkTheme.neonCyan,
        reverse: Bool = false
    ) {
        self.speed = max(0.0, min(1.0, speed))
        self.brightness = max(0.0, min(1.0, brightness))
        self.color = color
        self.reverse = reverse
    }

    /// Speed mapped to cycles per second (0.2 Hz to 2.5 Hz for realistic automotive motion)
    public var frequency: Double {
        let minHz = 0.25
        let maxHz = 2.4
        return minHz + (speed * (maxHz - minHz))
    }
}

public protocol LEDAnimation {
    /// Computes the luminous intensity at a normalized position (0.0 ... 1.0) along the continuous strip
    /// at the given elapsed time.
    ///
    /// - Parameters:
    ///   - position: Normalized coordinate along the strip [0.0, 1.0]
    ///   - time: Elapsed continuous time in seconds
    ///   - parameters: Current animation configuration
    /// - Returns: Computed intensity value in range [0.0, 1.0]
    func intensity(
        at position: CGFloat,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) -> CGFloat
}
