//
//  AppError.swift
//  SharkPowerV2
//
//  Human-friendly automotive errors with underlying technical diagnostics.
//

import Foundation

public enum AppError: LocalizedError, Identifiable {
    case bluetoothDisabled
    case bluetoothUnauthorized
    case deviceNotFound
    case connectionFailed(underlying: String)
    case applyFailed(reason: String)
    case protocolVerificationPending

    public var id: String {
        switch self {
        case .bluetoothDisabled: return "bt_disabled"
        case .bluetoothUnauthorized: return "bt_unauthorized"
        case .deviceNotFound: return "device_not_found"
        case .connectionFailed(let r): return "conn_\(r)"
        case .applyFailed(let r): return "apply_\(r)"
        case .protocolVerificationPending: return "proto_pending"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .bluetoothDisabled:
            return "Bluetooth is Turned Off"
        case .bluetoothUnauthorized:
            return "Bluetooth Access Needed"
        case .deviceNotFound:
            return "Device Not Found"
        case .connectionFailed:
            return "Connection Failed"
        case .applyFailed:
            return "Unable to Apply Settings"
        case .protocolVerificationPending:
            return "Protocol Pending Verification"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .bluetoothDisabled:
            return "Please enable Bluetooth in iOS Settings or Control Center to connect to Shark Power."
        case .bluetoothUnauthorized:
            return "Allow Bluetooth access in Settings to discover your LED controller."
        case .deviceNotFound:
            return "Ensure your Shark Power V2 light bar is powered on and within range."
        case .connectionFailed(let underlying):
            return "The Shark Power V2 could not be reached (\(underlying)). Please try again."
        case .applyFailed(let reason):
            return "The controller did not confirm the new configuration (\(reason)). Check device power."
        case .protocolVerificationPending:
            return "Hardware packet schema is running in simulation/abstract mode until physical hardware test."
        }
    }
}
