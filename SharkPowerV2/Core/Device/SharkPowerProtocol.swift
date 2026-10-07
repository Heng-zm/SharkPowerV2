//
//  SharkPowerProtocol.swift
//  SharkPowerV2
//
//  Isolated protocol encoder & decoder with configurable GATT UUIDs marked as Pending Verification.
//

import Foundation
import CoreBluetooth
import SwiftUI

public struct SharkPowerProtocolConfig: Equatable {
    /// Service UUID advertised by Shark Power V2 / SUPRE RACERS hardware.
    /// Default is marked as Pending Verification (TBD) to adhere to protocol safety rules.
    public var serviceUUID: CBUUID
    public var writeCharacteristicUUID: CBUUID
    public var notifyCharacteristicUUID: CBUUID
    public var isPendingVerification: Bool

    public static let pendingVerification = SharkPowerProtocolConfig(
        // Placeholder vendor UUID format pending hardware packet sniffing
        serviceUUID: CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB"),
        writeCharacteristicUUID: CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB"),
        notifyCharacteristicUUID: CBUUID(string: "0000FFF2-0000-1000-8000-00805F9B34FB"),
        isPendingVerification: true
    )

    public init(
        serviceUUID: CBUUID,
        writeCharacteristicUUID: CBUUID,
        notifyCharacteristicUUID: CBUUID,
        isPendingVerification: Bool = true
    ) {
        self.serviceUUID = serviceUUID
        self.writeCharacteristicUUID = writeCharacteristicUUID
        self.notifyCharacteristicUUID = notifyCharacteristicUUID
        self.isPendingVerification = isPendingVerification
    }
}

public final class SharkPowerProtocol: SharkPowerProtocol {
    public let config: SharkPowerProtocolConfig

    public init(config: SharkPowerProtocolConfig = .pendingVerification) {
        self.config = config
    }

    /// Encodes high-level lighting command into byte payload.
    /// NOTE: Byte schema adheres to the strict protocol abstraction guidelines.
    /// Hardware packet format is marked as TBD / Pending Verification.
    public func encode(_ command: LightingCommand) throws -> Data {
        var packet = Data()

        // Standardized abstraction framing: [Header: 0x53 ('S'), Opcode, Length, Payload..., Checksum]
        packet.append(0x53) // Prefix 'S' for Shark

        switch command {
        case .setMode(let mode):
            packet.append(0x01) // Opcode: Mode
            packet.append(0x01) // Length: 1
            let modeByte: UInt8 = {
                switch mode {
                case .forward: return 0x01
                case .reverse: return 0x02
                case .trailing: return 0x03
                case .chasing: return 0x04
                case .staticGlow: return 0x05
                }
            }()
            packet.append(modeByte)

        case .setColor(let r, let g, let b):
            packet.append(0x02) // Opcode: Color
            packet.append(0x03) // Length: 3
            packet.append(contentsOf: [r, g, b])

        case .setBrightness(let level):
            packet.append(0x03) // Opcode: Brightness
            packet.append(0x01)
            packet.append(level)

        case .setSpeed(let rate):
            packet.append(0x04) // Opcode: Speed
            packet.append(0x01)
            packet.append(rate)

        case .setFullConfiguration(let mode, let color, let brightness, let speed):
            packet.append(0x05) // Opcode: Full Configuration Sync
            packet.append(0x06) // Length: 6

            // Mode byte
            let mByte: UInt8 = {
                switch mode {
                case .forward: return 0x01
                case .reverse: return 0x02
                case .trailing: return 0x03
                case .chasing: return 0x04
                case .staticGlow: return 0x05
                }
            }()
            packet.append(mByte)

            // RGB Bytes
            let components = color.cgColor?.components ?? [0.0, 0.85, 1.0]
            let r = UInt8(max(0, min(255, (components[safe: 0] ?? 0.0) * 255)))
            let g = UInt8(max(0, min(255, (components[safe: 1] ?? 0.85) * 255)))
            let b = UInt8(max(0, min(255, (components[safe: 2] ?? 1.0) * 255)))
            packet.append(contentsOf: [r, g, b])

            // Brightness & Speed bytes
            packet.append(UInt8(max(0, min(255, brightness * 255))))
            packet.append(UInt8(max(0, min(255, speed * 255))))

        case .setPower(let isOn):
            packet.append(0x06)
            packet.append(0x01)
            packet.append(isOn ? 0x01 : 0x00)
        }

        // Add 8-bit checksum and footer
        let checksum = packet.reduce(0, { ($0 + $1) & 0xFF })
        packet.append(checksum)
        packet.append(0xAA) // Tail

        return packet
    }

    public func decode(_ data: Data) throws -> DeviceResponse {
        guard !data.isEmpty else {
            throw NSError(domain: "SharkPower.Protocol", code: 400, userInfo: [NSLocalizedDescriptionKey: "Empty packet received"])
        }

        // Basic validation of response payload
        let success = data.count >= 2 && data[0] == 0x53
        return DeviceResponse(success: success, rawData: data, description: "Received \(data.count) bytes")
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
