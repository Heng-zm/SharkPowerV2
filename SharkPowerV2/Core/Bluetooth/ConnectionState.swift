//
//  ConnectionState.swift
//  SharkPowerV2
//
//  Explicit state machine for Bluetooth hardware connection lifecycle.
//

import Foundation

public enum ConnectionState: Equatable {
    case idle
    case scanning
    case connecting(deviceId: String)
    case connected(deviceName: String)
    case disconnecting
    case disconnected
    case failed(reason: String)

    public var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    public var isScanning: Bool {
        if case .scanning = self { return true }
        return false
    }

    public var isConnecting: Bool {
        if case .connecting = self { return true }
        return false
    }

    public var displayText: String {
        switch self {
        case .idle:
            return "Ready"
        case .scanning:
            return "Searching for Shark Power..."
        case .connecting(let id):
            return "Connecting to \(id)..."
        case .connected(let name):
            return "Connected (\(name))"
        case .disconnecting:
            return "Disconnecting..."
        case .disconnected:
            return "Disconnected"
        case .failed(let reason):
            return "Connection Failed: \(reason)"
        }
    }
}
