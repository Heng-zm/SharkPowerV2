//
//  SharkPowerProtocol.swift
//  SharkPowerV2
//
//  Hardware protocol codec contract and unverified guard implementation.
//  RULE 1 & RULE 2 COMPLIANT: Throws until real hardware packets are verified.
//

import Foundation
import CoreBluetooth

public enum SharkPowerProtocolError: LocalizedError, Equatable {
    case unverifiedProtocol
    case packetEncodingFailed(String)
    case packetDecodingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .unverifiedProtocol:
            return "Shark Power V2 BLE protocol is TBD pending physical hardware packet capture. Real hardware writes remain disabled to prevent transmission of unverified packets."
        case .packetEncodingFailed(let detail):
            return "Protocol encoding error: \(detail)"
        case .packetDecodingFailed(let detail):
            return "Protocol decoding error: \(detail)"
        }
    }
}

public protocol SharkPowerProtocol: AnyObject {
    var config: SharkPowerProtocolConfig { get }
    func encode(_ command: LightingCommand) throws -> Data
    func decode(_ data: Data) throws -> DeviceResponse
}

/// Production implementation of SharkPowerProtocol.
/// In accordance with Rule 1 ("Do Not Guess") and Rule 2 ("Verified != Implemented"),
/// this class strictly guards against transmitting unverified packets to real hardware.
public final class DefaultSharkPowerProtocol: SharkPowerProtocol {
    public let config: SharkPowerProtocolConfig

    public init(config: SharkPowerProtocolConfig = .unverified) {
        self.config = config
    }

    /// Until physical reverse-engineering is complete, encoding throws to ensure
    /// unverified packets are never sent to physical hardware.
    public func encode(_ command: LightingCommand) throws -> Data {
        guard config.isVerified else {
            throw SharkPowerProtocolError.unverifiedProtocol
        }
        
        // Once verified on physical hardware, real packet serialization will be inserted here.
        throw SharkPowerProtocolError.unverifiedProtocol
    }

    /// Until physical reverse-engineering is complete, decoding throws to prevent false ACK assertions.
    public func decode(_ data: Data) throws -> DeviceResponse {
        guard config.isVerified else {
            throw SharkPowerProtocolError.unverifiedProtocol
        }

        guard !data.isEmpty else {
            throw SharkPowerProtocolError.packetDecodingFailed("Empty payload received")
        }

        return DeviceResponse(success: true, rawData: data, description: "Raw response payload (\(data.count) bytes)")
    }
}
