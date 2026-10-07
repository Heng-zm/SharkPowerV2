//
//  AppSettings.swift
//  SharkPowerV2
//
//  SwiftData persistent model tracking application settings and telemetry preferences.
//

import Foundation
import SwiftData

@Model
public final class AppSettings {
    public var id: UUID
    public var autoReconnect: Bool
    public var simulationModeEnabled: Bool
    public var hapticsEnabled: Bool
    public var highFramerateEnabled: Bool
    public var appearanceMode: String

    public init(
        id: UUID = UUID(),
        autoReconnect: Bool = true,
        simulationModeEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        highFramerateEnabled: Bool = true,
        appearanceMode: String = "Dark"
    ) {
        self.id = id
        self.autoReconnect = autoReconnect
        self.simulationModeEnabled = simulationModeEnabled
        self.hapticsEnabled = hapticsEnabled
        self.highFramerateEnabled = highFramerateEnabled
        self.appearanceMode = appearanceMode
    }
}
