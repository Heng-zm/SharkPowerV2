//
//  SharkPowerDevice.swift
//  SharkPowerV2
//
//  Unified controller aggregating Bluetooth connection, command queue, and protocol encoding.
//

import Foundation
import SwiftUI
import Combine

public final class SharkPowerDevice: ObservableObject {
    public static let shared = SharkPowerDevice()

    @Published public private(set) var connectionState: ConnectionState = .idle
    @Published public private(set) var eventLogs: [String] = []

    public let scanner: BLEScanner
    public let connection: BLEConnection
    public let gattClient: BLEGATTClient
    public let commandQueue: BLECommandQueue
    public let hardwareProtocol: SharkPowerProtocol

    private var cancellables = Set<AnyCancellable>()

    public init(
        scanner: BLEScanner = BLEScanner(),
        connection: BLEConnection = BLEConnection(),
        gattClient: BLEGATTClient = BLEGATTClient(),
        hardwareProtocol: SharkPowerProtocol = DefaultSharkPowerProtocol()
    ) {
        self.scanner = scanner
        self.connection = connection
        self.gattClient = gattClient
        self.hardwareProtocol = hardwareProtocol
        self.commandQueue = BLECommandQueue(gattClient: gattClient)

        setupSubscriptions()
        log("SharkPowerDevice initialized. Protocol isVerified: \(hardwareProtocol.config.isVerified)")
    }

    private func setupSubscriptions() {
        connection.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.connectionState = state
                self.log("Connection state transitioned to: \(state.displayText)")
                if case .connected = state {
                    self.gattClient.attach(peripheral: self.connection.currentDevice?.peripheral)
                    self.gattClient.discoverServices()
                } else if case .disconnected = state {
                    Task {
                        await self.commandQueue.clear()
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func connect(to device: BLEDevice) {
        log("Initiating connection to \(device.name)")
        connection.connect(to: device)
    }

    public func disconnect() {
        log("Disconnecting from device")
        connection.disconnect()
    }

    public func applyConfiguration(
        mode: LEDMode,
        color: Color,
        brightness: Double,
        speed: Double
    ) async throws {
        let command = LightingCommand.setFullConfiguration(
            mode: mode,
            color: color,
            brightness: brightness,
            speed: speed
        )

        if SimulationManager.shared.isEnabled {
            log("SIMULATION: Dispatching configuration to simulated device")
            try await withCheckedThrowingContinuation { continuation in
                SimulationManager.shared.simulateApply(command: command) { result in
                    switch result {
                    case .success(let resp):
                        self.log("SIMULATION: \(resp.description)")
                        continuation.resume()
                    case .failure(let err):
                        self.log("SIMULATION ERROR: \(err.localizedDescription)")
                        continuation.resume(throwing: err)
                    }
                }
            }
            return
        }

        // Live Hardware Path
        log("Applying configuration to physical Shark Power hardware...")
        guard hardwareProtocol.config.isVerified else {
            log("BLOCKED: Hardware protocol is TBD. Unverified packet dispatch prevented.")
            throw SharkPowerProtocolError.unverifiedProtocol
        }

        let encodedData = try hardwareProtocol.encode(command)
        guard let writeUUID = hardwareProtocol.config.writeCharacteristicUUID else {
            throw SharkPowerProtocolError.unverifiedProtocol
        }

        await commandQueue.enqueue(
            data: encodedData,
            characteristicUUID: writeUUID,
            deduplicationKey: command.deduplicationKey,
            requiresResponse: false
        )

        log("Dispatched configuration packet (\(encodedData.count) bytes)")
    }

    public func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let formatted = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.eventLogs.append(formatted)
            if self.eventLogs.count > 100 {
                self.eventLogs.removeFirst()
            }
        }
    }
}
