//
//  BLEDevice.swift
//  SharkPowerV2
//
//  Model representing a discovered Bluetooth Low Energy lighting peripheral.
//

import Foundation
import CoreBluetooth

public struct BLEDevice: Identifiable, Equatable {
    public let id: UUID
    public let peripheral: CBPeripheral?
    public let name: String
    public var rssi: Int
    public let advertisedServices: [CBUUID]
    public let lastSeen: Date

    public init(
        id: UUID = UUID(),
        peripheral: CBPeripheral? = nil,
        name: String = "Shark Power V2",
        rssi: Int = -60,
        advertisedServices: [CBUUID] = [],
        lastSeen: Date = Date()
    ) {
        self.id = id
        self.peripheral = peripheral
        self.name = name
        self.rssi = rssi
        self.advertisedServices = advertisedServices
        self.lastSeen = lastSeen
    }

    /// Normalized signal strength 0.0 ... 1.0 (e.g. -100 dBm is ~0%, -40 dBm is ~100%)
    public var signalStrength: Double {
        let clamped = max(-100, min(-40, rssi))
        return Double(clamped - (-100)) / 60.0
    }

    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.id == rhs.id
    }
}
