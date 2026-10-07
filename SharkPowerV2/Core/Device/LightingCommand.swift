//
//  LightingCommand.swift
//  SharkPowerV2
//
//  Decoupled hardware-agnostic lighting control intent models.
//

import SwiftUI

public enum LightingCommand: Equatable {
    case setMode(LEDMode)
    case setColor(red: UInt8, green: UInt8, blue: UInt8)
    case setBrightness(UInt8)
    case setSpeed(UInt8)
    case setFullConfiguration(mode: LEDMode, color: Color, brightness: Double, speed: Double)
    case setPower(Bool)

    public var deduplicationKey: String {
        switch self {
        case .setMode: return "mode"
        case .setColor: return "color"
        case .setBrightness: return "brightness"
        case .setSpeed: return "speed"
        case .setFullConfiguration: return "full_config"
        case .setPower: return "power"
        }
    }
}

public struct DeviceResponse: Equatable {
    public let success: Bool
    public let rawData: Data
    public let description: String

    public init(success: Bool, rawData: Data = Data(), description: String = "ACK") {
        self.success = success
        self.rawData = rawData
        self.description = description
    }
}
