//
//  BLEScannerTests.swift
//  SharkPowerV2Tests
//
//  Unit tests for BLE device discovery and RSSI normalization.
//

import XCTest
import CoreBluetooth
@testable import SharkPowerV2

final class BLEScannerTests: XCTestCase {

    func testDeviceSignalStrengthNormalization() {
        let strongDevice = BLEDevice(id: UUID(), name: "Shark Power", rssi: -40)
        XCTAssertEqual(strongDevice.signalStrength, 1.0, accuracy: 0.05)

        let weakDevice = BLEDevice(id: UUID(), name: "Shark Power", rssi: -100)
        XCTAssertEqual(weakDevice.signalStrength, 0.0, accuracy: 0.05)

        let midDevice = BLEDevice(id: UUID(), name: "Shark Power", rssi: -70)
        XCTAssertEqual(midDevice.signalStrength, 0.5, accuracy: 0.05)
    }

    func testConnectionStateFlags() {
        let idle = ConnectionState.idle
        XCTAssertFalse(idle.isConnected)
        XCTAssertFalse(idle.isConnecting)

        let connecting = ConnectionState.connecting(deviceId: "Device1")
        XCTAssertTrue(connecting.isConnecting)
        XCTAssertFalse(connecting.isConnected)

        let connected = ConnectionState.connected(deviceName: "Shark Power V2")
        XCTAssertTrue(connected.isConnected)
        XCTAssertFalse(connected.isConnecting)
    }
}
