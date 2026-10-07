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
        hardwareProtocol: SharkPowerProtocol = SharkPowerProtocol()
    ) {
        self.scanner = scanner
        self.connection = connection
        self.gattClient = gattClient
        self.hardwareProtocol = hardwareProtocol
        self.commandQueue = BLECommandQueue(gattClient: gattClient)

        setupSubscriptions()
        log("SharkPowerDevice initialized. Protocol isPendingVerification: \(hardwareProtocol.config.isPendingVerification)")
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

    /// Sends the complete lighting configuration to the connected device upon tapping APPLY.
    public func applyConfiguration(
        mode: LEDMode,
        color: Color,
        brightness: Double,
        speed: Double
    ) async throws {
        log("Applying configuration: Mode=\(mode.rawValue), Brightness=\(Int(brightness*100))%, Speed=\(Int(speed*100))%")

        let command = LightingCommand.setFullConfiguration(
            mode: mode,
            color: color,
            brightness: brightness,
            speed: speed
        )

        let encodedData = try hardwareProtocol.encode(command)

        await commandQueue.enqueue(
            data: encodedData,
            characteristicUUID: hardwareProtocol.config.writeCharacteristicUUID,
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
