//
//  DevicesViewModel.swift
//  SharkPowerV2
//
//  Coordinates Bluetooth peripheral scanning, signal meters, and connection lifecycle.
//

import SwiftUI
import Combine

@MainActor
public final class DevicesViewModel: ObservableObject {
    @Published public private(set) var discoveredDevices: [BLEDevice] = []
    @Published public private(set) var connectionState: ConnectionState = .idle
    @Published public private(set) var isScanning: Bool = false
    @Published public var isSimulationEnabled: Bool = false
    @Published public var selectedDeviceForDetails: BLEDevice?

    private let device: SharkPowerDevice
    private var cancellables = Set<AnyCancellable>()

    public init(device: SharkPowerDevice = .shared) {
        self.device = device
        setupBindings()
    }

    private func setupBindings() {
        device.scanner.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredDevices)

        device.$connectionState
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)

        device.scanner.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isScanning)

        device.scanner.$bluetoothState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    public var isBluetoothPoweredOff: Bool {
        device.scanner.bluetoothState == .poweredOff
    }

    public var isBluetoothUnauthorized: Bool {
        device.scanner.authorizationDenied
    }

    public func startScanning() {
        device.scanner.isSimulationEnabled = isSimulationEnabled
        device.scanner.startScanning()
        Haptics.shared.lightImpact()
    }

    public func stopScanning() {
        device.scanner.stopScanning()
    }

    public func connect(to deviceItem: BLEDevice) {
        Haptics.shared.mediumImpact()
        device.connect(to: deviceItem)
    }

    public func disconnect() {
        Haptics.shared.lightImpact()
        device.disconnect()
    }

    public func toggleSimulation() {
        isSimulationEnabled.toggle()
        device.scanner.isSimulationEnabled = isSimulationEnabled
        if isSimulationEnabled {
            startScanning()
        }
    }
}
