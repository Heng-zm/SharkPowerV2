//
//  BLEProtocols.swift
//  SharkPowerV2
//
//  Abstract protocol interfaces decoupling Bluetooth hardware interactions from UI.
//

import Foundation
import CoreBluetooth

public protocol BLEScanning: AnyObject {
    var isScanning: Bool { get }
    var discoveredDevices: [BLEDevice] { get }
    func startScanning()
    func stopScanning()
}

public protocol BLEConnecting: AnyObject {
    var state: ConnectionState { get }
    func connect(to device: BLEDevice)
    func disconnect()
}

public protocol BLEGATTClientProtocol: AnyObject {
    func discoverServices()
    func write(data: Data, characteristicUUID: CBUUID, responseNeeded: Bool) async throws
    func subscribe(characteristicUUID: CBUUID, onNotification: @escaping (Data) -> Void) throws
}

