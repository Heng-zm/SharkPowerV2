//
//  SimulationManager.swift
//  SharkPowerV2
//
//  Complete simulation manager enabling offline UX validation without physical hardware.
//  RULE 2 COMPLIANT: Clearly marks all operations as SIMULATION MODE.
//

import Foundation
import SwiftUI
import Combine

public final class SimulationManager: ObservableObject {
    public static let shared = SimulationManager()

    @Published public var isEnabled: Bool = false
    @Published public private(set) var simulatedDevice: FakeBLEDevice
    @Published public private(set) var simulatedConnectionState: ConnectionState = .idle
    @Published public var shouldSimulateErrors: Bool = false
    @Published public private(set) var simulatedLogs: [String] = []
    public var simulatedLatency: TimeInterval = 0.05

    private var heartbeatTimer: AnyCancellable?

    public init() {
        self.simulatedDevice = FakeBLEDevice()
        #if targetEnvironment(simulator)
        self.isEnabled = true
        #endif
    }

    public func startScanning(onDeviceDiscovered: @escaping (BLEDevice) -> Void) {
        guard isEnabled else { return }
        simulatedConnectionState = .scanning
        log("SIMULATION: Scanning for simulated Shark Power devices...")

        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLatency) { [weak self] in
            guard let self = self, self.isEnabled else { return }
            let device = self.simulatedDevice.toBLEDevice()
            onDeviceDiscovered(device)
            self.log("SIMULATION: Discovered \(device.name) (RSSI: \(device.rssi) dBm)")
        }

        // Periodic RSSI fluctuation
        heartbeatTimer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isEnabled else { return }
                self.simulatedDevice.simulateRSSIFluctuation()
            }
    }

    public func connect(onStateChanged: @escaping (ConnectionState) -> Void) {
        guard isEnabled else { return }
        simulatedConnectionState = .connecting(deviceId: simulatedDevice.name)
        onStateChanged(simulatedConnectionState)
        log("SIMULATION: Connecting to \(simulatedDevice.name)...")

        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLatency) { [weak self] in
            guard let self = self else { return }
            if self.shouldSimulateErrors {
                self.simulatedConnectionState = .failed(reason: "Simulated peripheral timeout")
                onStateChanged(self.simulatedConnectionState)
                self.log("SIMULATION ERROR: Connection timed out")
            } else {
                self.simulatedDevice.isConnected = true
                self.simulatedConnectionState = .connected(deviceName: self.simulatedDevice.name)
                onStateChanged(self.simulatedConnectionState)
                self.log("SIMULATION: Connected to \(self.simulatedDevice.name)")
            }
        }
    }

    public func disconnect(onStateChanged: @escaping (ConnectionState) -> Void) {
        guard isEnabled else { return }
        simulatedDevice.isConnected = false
        simulatedConnectionState = .disconnected
        onStateChanged(simulatedConnectionState)
        log("SIMULATION: Disconnected from simulated device")
    }

    public func simulateApply(
        command: LightingCommand,
        completion: @escaping (Result<DeviceResponse, Error>) -> Void
    ) {
        guard isEnabled else {
            completion(.failure(SharkPowerProtocolError.unverifiedProtocol))
            return
        }

        log("SIMULATION: Emulating Apply command dispatch...")

        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLatency) { [weak self] in
            guard let self = self else { return }
            if self.shouldSimulateErrors {
                let err = NSError(domain: "SharkPower.Simulation", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated hardware NACK"])
                self.log("SIMULATION ERROR: Command rejected by simulated peripheral")
                completion(.failure(err))
            } else {
                let resp = DeviceResponse(success: true, rawData: Data(), description: "Simulated ACK received")
                self.log("SIMULATION: Command applied successfully to simulated preview state")
                completion(.success(resp))
            }
        }
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let formatted = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.simulatedLogs.append(formatted)
            if self.simulatedLogs.count > 100 {
                self.simulatedLogs.removeFirst()
            }
        }
    }
}
