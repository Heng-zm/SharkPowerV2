//
//  ModelContainer.swift
//  SharkPowerV2
//
//  SwiftData container configuration with automated preset seeding.
//

import Foundation
import SwiftData
import SwiftUI

public enum SharkModelContainer {
    public static func create(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            SavedPreset.self,
            KnownDevice.self,
            AppSettings.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            seedDefaultPresetsIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    private static func seedDefaultPresetsIfNeeded(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<SavedPreset>()
            let count = try context.fetchCount(descriptor)
            if count == 0 {
                let defaults: [SavedPreset] = [
                    SavedPreset(
                        name: "Cyber Neon",
                        mode: LEDMode.forward.rawValue,
                        colorHex: SharkTheme.neonCyan.toHex(),
                        brightness: 0.9,
                        speed: 0.6
                    ),
                    SavedPreset(
                        name: "Sport Chasing",
                        mode: LEDMode.chasing.rawValue,
                        colorHex: SharkTheme.electricBlue.toHex(),
                        brightness: 1.0,
                        speed: 0.75
                    ),
                    SavedPreset(
                        name: "Demon Eye Red",
                        mode: LEDMode.trailing.rawValue,
                        colorHex: SharkTheme.daytonaRed.toHex(),
                        brightness: 0.95,
                        speed: 0.5
                    ),
                    SavedPreset(
                        name: "Amber Sequential",
                        mode: LEDMode.forward.rawValue,
                        colorHex: SharkTheme.cyberAmber.toHex(),
                        brightness: 1.0,
                        speed: 0.45
                    ),
                    SavedPreset(
                        name: "Solid Xenon White",
                        mode: LEDMode.staticGlow.rawValue,
                        colorHex: SharkTheme.pureWhite.toHex(),
                        brightness: 0.8,
                        speed: 0.3
                    )
                ]

                for preset in defaults {
                    context.insert(preset)
                }
                try context.save()
            }
        } catch {
            print("Failed to seed default presets: \(error)")
        }
    }
}
