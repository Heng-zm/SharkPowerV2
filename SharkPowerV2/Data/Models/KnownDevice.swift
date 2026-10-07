//
//  KnownDevice.swift
//  SharkPowerV2
//
//  SwiftData persistent model tracking previously paired Shark Power hardware.
//

import Foundation
import SwiftData

@Model
public final class KnownDevice {
    public var id: UUID
    public var name: String
    public var identifier: String
    public var lastConnectedAt: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        identifier: String,
        lastConnectedAt: Date? = Date()
    ) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.lastConnectedAt = lastConnectedAt
    }
}
