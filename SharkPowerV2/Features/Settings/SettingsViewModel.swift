//
//  SettingsViewModel.swift
//  SharkPowerV2
//
//  Manages app configuration, diagnostics logs, appearance, and hardware inspection.
//

import SwiftUI
import Combine

@MainActor
public final class SettingsViewModel: ObservableObject {
    @AppStorage("autoReconnect") public var autoReconnect: Bool = true
    @AppStorage("hapticFeedbackEnabled") public var hapticFeedbackEnabled: Bool = true
    @AppStorage("highFramerateEnabled") public var highFramerateEnabled: Bool = true
    @AppStorage("appearanceMode") public var appearanceMode: String = "Dark"

    @Published public private(set) var eventLogs: [String] = []
    @Published public private(set) var connectionState: ConnectionState = .idle
    @Published public private(set) var discoveredServicesCount: Int = 0
    @Published public private(set) var discoveredCharacteristicsCount: Int = 0

    private let device: SharkPowerDevice
    private var cancellables = Set<AnyCancellable>()

    public init(device: SharkPowerDevice = .shared) {
        self.device = device
        setupBindings()
    }

    private func setupBindings() {
        device.$eventLogs
            .receive(on: DispatchQueue.main)
            .assign(to: &$eventLogs)

        device.$connectionState
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)

        device.gattClient.$discoveredServices
            .map { $0.count }
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredServicesCount)

        device.gattClient.$discoveredCharacteristics
            .map { $0.count }
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredCharacteristicsCount)
    }

    public var connectedDeviceName: String {
        if case .connected(let name) = connectionState {
            return name
        }
        return "None"
    }

    public var protocolVerificationStatus: String {
        device.hardwareProtocol.config.isPendingVerification ? "Pending Hardware Verification" : "Verified"
    }

    public func forgetCurrentDevice() {
        Haptics.shared.lightImpact()
        device.disconnect()
    }

    public func clearLogs() {
        device.log("Logs cleared by user")
    }
}
