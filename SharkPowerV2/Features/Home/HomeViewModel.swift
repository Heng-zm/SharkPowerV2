//
//  HomeViewModel.swift
//  SharkPowerV2
//
//  State coordinator for the primary cockpit dashboard and live lighting preview.
//

import SwiftUI
import Combine

public enum ApplyState: Equatable {
    case idle
    case applying
    case applied
    case failed(String)
}

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var draftState: DraftLightingState = DraftLightingState()

    public var selectedMode: LEDMode {
        get { draftState.mode }
        set { draftState.mode = newValue }
    }

    public var parameters: LEDAnimationParameters {
        get { draftState.parameters }
        set { draftState.parameters = newValue }
    }

    @Published public var applyState: ApplyState = .idle
    @Published public var showColorPicker: Bool = false
    @Published public var showModeSheet: Bool = false
    @Published public var showFullScreenPreview: Bool = false
    @Published public var showSavePresetSheet: Bool = false
    @Published public var presetNameInput: String = ""

    private let device: SharkPowerDevice
    private var cancellables = Set<AnyCancellable>()

    public init(device: SharkPowerDevice = .shared) {
        self.device = device
    }

    public var connectionState: ConnectionState {
        device.connectionState
    }

    public var isConnected: Bool {
        device.connectionState.isConnected
    }

    public var deviceName: String {
        if case .connected(let name) = device.connectionState {
            return name
        }
        return "Not Connected"
    }

    public func applyToDevice() {
        guard !applyState.isApplying else { return }

        applyState = .applying
        Haptics.shared.mediumImpact()

        Task {
            do {
                try await device.applyConfiguration(
                    mode: selectedMode,
                    color: parameters.color,
                    brightness: parameters.brightness,
                    speed: parameters.speed
                )
                
                withAnimation(.spring) {
                    self.applyState = .applied
                }
                Haptics.shared.notifySuccess()

                // Return to idle after 2.5 seconds
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                withAnimation {
                    if case .applied = self.applyState {
                        self.applyState = .idle
                    }
                }
            } catch {
                withAnimation {
                    self.applyState = .failed(error.localizedDescription)
                }
                Haptics.shared.notifyError()
            }
        }
    }

    public func loadPreset(mode: LEDMode, colorHex: String, brightness: Double, speed: Double) {
        self.draftState = DraftLightingState(
            mode: mode,
            parameters: LEDAnimationParameters(
                speed: speed,
                brightness: brightness,
                color: Color(hex: colorHex)
            )
        )
        Haptics.shared.selectionChanged()
    }
}

extension ApplyState {
    public var isApplying: Bool {
        if case .applying = self { return true }
        return false
    }
}
