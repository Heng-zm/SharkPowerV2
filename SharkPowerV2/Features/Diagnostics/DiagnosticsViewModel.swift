//
//  DiagnosticsViewModel.swift
//  SharkPowerV2
//
//  Telemetry coordinator aggregating low-level CoreBluetooth, GATT, and queue diagnostic states.
//

import SwiftUI
import CoreBluetooth
import Combine

@MainActor
public final class DiagnosticsViewModel: ObservableObject {
    @Published public private(set) var bluetoothStateString: String = "Unknown"
    @Published public private(set) var isScanning: Bool = false
    @Published public private(set) var connectionStateString: String = "Idle"
    @Published public private(set) var activeDeviceId: String = "None"
    @Published public private(set) var rssiString: String = "--"
    @Published public private(set) var discoveredServices: [String] = []
    @Published public private(set) var discoveredCharacteristics: [String] = []
    @Published public private(set) var eventLogs: [String] = []
    @Published public private(set) var isSimulationActive: Bool = false

    private let device: SharkPowerDevice
    private let simulationManager: SimulationManager
    private var cancellables = Set<AnyCancellable>()

    public init(
        device: SharkPowerDevice = .shared,
        simulationManager: SimulationManager = .shared
    ) {
        self.device = device
        self.simulationManager = simulationManager
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        device.scanner.$bluetoothState
            .map { state -> String in
                switch state {
                case .poweredOn: return "Powered On (Ready)"
                case .poweredOff: return "Powered Off"
                case .unauthorized: return "Unauthorized (Check Settings)"
                case .unsupported: return "Unsupported Hardware"
                case .resetting: return "Resetting"
                case .unknown: return "Unknown"
                @unknown default: return "Unknown State"
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$bluetoothStateString)

        device.scanner.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isScanning)

        device.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.connectionStateString = state.displayText
                if case .connected(let name) = state {
                    self.activeDeviceId = name
                } else if case .connecting(let id) = state {
                    self.activeDeviceId = id
                } else {
                    self.activeDeviceId = "None"
                }
            }
            .store(in: &cancellables)

        device.connection.$lastRssi
            .map { "\($0) dBm" }
            .receive(on: DispatchQueue.main)
            .assign(to: &$rssiString)

        device.gattClient.$discoveredServices
            .map { $0.map { $0.uuid.uuidString } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredServices)

        device.gattClient.$discoveredCharacteristics
            .map { $0.map { "\($0.uuid.uuidString) (\(self.formatProperties($0.properties)))" } }
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredCharacteristics)

        device.$eventLogs
            .receive(on: DispatchQueue.main)
            .assign(to: &$eventLogs)

        simulationManager.$isEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSimulationActive)
    }

    private func formatProperties(_ props: CBCharacteristicProperties) -> String {
        var list: [String] = []
        if props.contains(.read) { list.append("Read") }
        if props.contains(.write) { list.append("Write") }
        if props.contains(.writeWithoutResponse) { list.append("WriteNoResp") }
        if props.contains(.notify) { list.append("Notify") }
        if props.contains(.indicate) { list.append("Indicate") }
        return list.isEmpty ? "None" : list.joined(separator: ", ")
    }

    public var protocolStatusText: String {
        device.hardwareProtocol.config.isVerified ? "VERIFIED (Hardware Confirmed)" : "TBD (Pending Physical Sniffing)"
    }
}
