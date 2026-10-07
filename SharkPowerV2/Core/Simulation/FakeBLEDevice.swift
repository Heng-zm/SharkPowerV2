//
//  FakeBLEDevice.swift
//  SharkPowerV2
//
//  Simulated BLE peripheral for offline preview and comprehensive QA testing.
//

import Foundation
import CoreBluetooth

public final class FakeBLEDevice: ObservableObject, Identifiable {
    public let id: UUID
    public let name: String
    @Published public var rssi: Int
    @Published public var isConnected: Bool = false
    public let simulatedServiceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    public let simulatedWriteCharacteristicUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")

    public init(
        id: UUID = UUID(),
        name: String = "Shark Power V2 (Simulated)",
        rssi: Int = -56
    ) {
        self.id = id
        self.name = name
        self.rssi = rssi
    }

    /// Converts to BLEDevice presentation model
    public func toBLEDevice() -> BLEDevice {
        BLEDevice(
            id: id,
            peripheral: nil,
            name: name,
            rssi: rssi,
            advertisedServices: [simulatedServiceUUID],
            lastSeen: Date()
        )
    }

    public func simulateRSSIFluctuation() {
        let delta = Int.random(in: -3...3)
        rssi = max(-95, min(-45, rssi + delta))
    }
}
