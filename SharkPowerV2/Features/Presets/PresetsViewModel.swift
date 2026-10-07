//
//  PresetsViewModel.swift
//  SharkPowerV2
//
//  Manages saved sequential LED presets and batch applications.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
public final class PresetsViewModel: ObservableObject {
    @Published public var selectedPresetForEdit: SavedPreset?
    @Published public var editName: String = ""
    @Published public var isApplying: Bool = false

    private let device: SharkPowerDevice

    public init(device: SharkPowerDevice = .shared) {
        self.device = device
    }

    public func applyPreset(_ preset: SavedPreset) {
        Haptics.shared.mediumImpact()
        isApplying = true

        Task {
            do {
                try await device.applyConfiguration(
                    mode: preset.ledMode,
                    color: preset.color,
                    brightness: preset.brightness,
                    speed: preset.speed
                )
                Haptics.shared.notifySuccess()
            } catch {
                Haptics.shared.notifyError()
            }
            self.isApplying = false
        }
    }

    public func deletePreset(_ preset: SavedPreset, context: ModelContext) {
        Haptics.shared.lightImpact()
        context.delete(preset)
        try? context.save()
    }
}
