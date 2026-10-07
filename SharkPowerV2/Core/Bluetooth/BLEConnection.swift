//
//  BLEConnection.swift
//  SharkPowerV2
//
//  Manages peripheral connection state machine and connection lifecycles.
//

import Foundation
import CoreBluetooth
import Combine

public final class BLEConnection: NSObject, ObservableObject, BLEConnecting {
    @Published public private(set) var state: ConnectionState = .idle
    @Published public private(set) var currentDevice: BLEDevice?
    @Published public private(set) var lastRssi: Int = -60

    private var centralManager: CBCentralManager?
    private var activePeripheral: CBPeripheral?
    private var reconnectTimer: AnyCancellable?
    private var isSimulated: Bool = false

    public override init() {
        super.init()
    }

    public func configure(centralManager: CBCentralManager?) {
        self.centralManager = centralManager
    }

    public func connect(to device: BLEDevice) {
        currentDevice = device
        state = .connecting(deviceId: device.name)

        if device.peripheral == nil {
            // Simulated connection for previews / simulator testing
            isSimulated = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                guard let self = self else { return }
                self.state = .connected(deviceName: device.name)
                Haptics.shared.notifySuccess()
            }
            return
        }

        isSimulated = false
        activePeripheral = device.peripheral
        activePeripheral?.delegate = self

        guard let peripheral = activePeripheral, let central = centralManager else {
            state = .failed(reason: "Bluetooth central manager unavailable")
            return
        }

        central.connect(peripheral, options: [
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
    }

    public func disconnect() {
        if isSimulated {
            state = .disconnected
            currentDevice = nil
            return
        }

        guard let peripheral = activePeripheral, let central = centralManager else {
            state = .disconnected
            currentDevice = nil
            return
        }

        state = .disconnecting
        central.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Central Delegate Forwarding
    public func handleConnected(peripheral: CBPeripheral) {
        activePeripheral = peripheral
        state = .connected(deviceName: peripheral.name ?? "Shark Power V2")
        Haptics.shared.notifySuccess()
    }

    public func handleDisconnected(peripheral: CBPeripheral, error: Error?) {
        activePeripheral = nil
        if let error = error {
            state = .failed(reason: error.localizedDescription)
            Haptics.shared.notifyWarning()
        } else {
            state = .disconnected
        }
    }

    public func handleFailedToConnect(peripheral: CBPeripheral, error: Error?) {
        activePeripheral = nil
        let reason = error?.localizedDescription ?? "Failed to establish connection"
        state = .failed(reason: reason)
        Haptics.shared.notifyError()
    }
}

// MARK: - CBPeripheralDelegate
extension BLEConnection: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if error == nil {
            self.lastRssi = RSSI.intValue
        }
    }
}
