//
//  BLEGATTClient.swift
//  SharkPowerV2
//
//  GATT Service and Characteristic discovery, packet writing, and notification handler.
//

import Foundation
import CoreBluetooth

public final class BLEGATTClient: NSObject, ObservableObject, BLEGATTClient {
    @Published public private(set) var discoveredServices: [CBService] = []
    @Published public private(set) var discoveredCharacteristics: [CBCharacteristic] = []

    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var notificationHandlers: [CBUUID: (Data) -> Void] = [:]

    public func attach(peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        self.discoveredServices.removeAll()
        self.discoveredCharacteristics.removeAll()
    }

    public func discoverServices() {
        guard let peripheral = peripheral else { return }
        peripheral.discoverServices(nil)
    }

    public func write(data: Data, characteristicUUID: CBUUID, responseNeeded: Bool = false) async throws {
        guard let peripheral = peripheral else {
            // In simulation mode, silently succeed
            return
        }

        guard let targetCharacteristic = discoveredCharacteristics.first(where: { $0.uuid == characteristicUUID }) ?? writeCharacteristic else {
            throw NSError(domain: "SharkPower.GATT", code: 404, userInfo: [NSLocalizedDescriptionKey: "Target write characteristic not found: \(characteristicUUID)"])
        }

        let writeType: CBCharacteristicWriteType = responseNeeded ? .withResponse : .withoutResponse
        peripheral.writeValue(data, for: targetCharacteristic, type: writeType)
    }

    public func subscribe(characteristicUUID: CBUUID, onNotification: @escaping (Data) -> Void) throws {
        notificationHandlers[characteristicUUID] = onNotification
        guard let peripheral = peripheral,
              let char = discoveredCharacteristics.first(where: { $0.uuid == characteristicUUID }) else {
            return
        }
        peripheral.setNotifyValue(true, for: char)
    }
}

// MARK: - CBPeripheralDelegate (GATT)
extension BLEGATTClient: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let services = peripheral.services else { return }
        self.discoveredServices = services
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristics = service.characteristics else { return }
        self.discoveredCharacteristics.append(contentsOf: characteristics)

        // Auto-assign write characteristic candidate
        for char in characteristics {
            if char.properties.contains(.write) || char.properties.contains(.writeWithoutResponse) {
                if self.writeCharacteristic == nil {
                    self.writeCharacteristic = char
                }
            }
            if char.properties.contains(.notify) {
                if self.notifyCharacteristic == nil {
                    self.notifyCharacteristic = char
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        notificationHandlers[characteristic.uuid]?(data)
    }
}
