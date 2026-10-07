//
//  SavedPreset.swift
//  SharkPowerV2
//
//  SwiftData persistent model for user-defined sequential LED presets.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public final class SavedPreset {
    public var id: UUID
    public var name: String
    public var mode: String
    public var colorHex: String
    public var brightness: Double
    public var speed: Double
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        mode: String,
        colorHex: String,
        brightness: Double,
        speed: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.mode = mode
        self.colorHex = colorHex
        self.brightness = brightness
        self.speed = speed
        self.createdAt = createdAt
    }

    public var modeRawValue: String {
        mode
    }

    /// Safely resolves the saved mode. If unknown or missing, falls back to .forward without crashing.
    public var lightingMode: LightingMode {
        LightingMode(rawValue: mode) ?? .forward
    }

    public var ledMode: LEDMode {
        lightingMode
    }

    /// Indicates whether the saved mode rawValue corresponds to a known, supported LightingMode.
    public var isRecognizedMode: Bool {
        LightingMode(rawValue: mode) != nil
    }

    public var color: Color {
        Color(hex: colorHex)
    }

    public var animationParameters: LEDAnimationParameters {
        LEDAnimationParameters(
            speed: speed,
            brightness: brightness,
            color: color
        )
    }
}
