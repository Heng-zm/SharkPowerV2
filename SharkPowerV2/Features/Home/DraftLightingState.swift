//
//  DraftLightingState.swift
//  SharkPowerV2
//
//  Decoupled draft lighting configuration state used for live on-screen experimentation.
//

import SwiftUI

public struct DraftLightingState: Equatable {
    public var mode: LEDMode
    public var parameters: LEDAnimationParameters

    public init(
        mode: LEDMode = .forward,
        parameters: LEDAnimationParameters = LEDAnimationParameters(speed: 0.55, brightness: 0.90, color: SharkTheme.neonCyan)
    ) {
        self.mode = mode
        self.parameters = parameters
    }

    public func toLightingCommand() -> LightingCommand {
        LightingCommand.setFullConfiguration(
            mode: mode,
            color: parameters.color,
            brightness: parameters.brightness,
            speed: parameters.speed
        )
    }
}
