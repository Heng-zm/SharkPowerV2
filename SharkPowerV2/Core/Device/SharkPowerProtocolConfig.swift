//
//  SharkPowerProtocolConfig.swift
//  SharkPowerV2
//
//  Configuration for Shark Power V2 GATT UUIDs.
//  RULE 1 COMPLIANT: UUIDs default to nil until captured from physical hardware.
//

import Foundation
import CoreBluetooth

public struct SharkPowerProtocolConfig: Equatable {
    /// Service UUID advertised by the physical Shark Power V2 hardware.
    /// Value is nil until captured and verified from real hardware.
    public let serviceUUID: CBUUID?

    /// Characteristic UUID used for writing lighting commands.
    /// Value is nil until verified.
    public let writeCharacteristicUUID: CBUUID?

    /// Characteristic UUID used for notifications/indications.
    /// Value is nil until verified.
    public let notifyCharacteristicUUID: CBUUID?

    /// Indicates whether the protocol has been confirmed on real hardware.
    public var isVerified: Bool {
        serviceUUID != nil && writeCharacteristicUUID != nil
    }

    /// Default unverified configuration strictly adhering to "Do Not Guess" policy.
    public static let unverified = SharkPowerProtocolConfig(
        serviceUUID: nil,
        writeCharacteristicUUID: nil,
        notifyCharacteristicUUID: nil
    )

    public init(
        serviceUUID: CBUUID? = nil,
        writeCharacteristicUUID: CBUUID? = nil,
        notifyCharacteristicUUID: CBUUID? = nil
    ) {
        self.serviceUUID = serviceUUID
        self.writeCharacteristicUUID = writeCharacteristicUUID
        self.notifyCharacteristicUUID = notifyCharacteristicUUID
    }
}
