//
//  BLEScanner.swift
//  SharkPowerV2
//
//  Production-ready CoreBluetooth CBCentralManager wrapper for discovering Shark Power hardware.
//

import Foundation
import CoreBluetooth
import Combine

public final class BLEScanner: NSObject, ObservableObject, BLEScanning {
    @Published public private(set) var isScanning: Bool = false
    @Published public private(set) var discoveredDevices: [BLEDevice] = []
    @Published public private(set) var bluetoothState: CBManagerState = .unknown
    @Published public var authorizationDenied: Bool = false

    private var centralManager: CBCentralManager?
    private var simulatedScanTimer: AnyCancellable?
    public var isSimulationEnabled: Bool = false

    public override init() {
        super.init()
        #if !targetEnvironment(simulator)
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        #else
        self.isSimulationEnabled = true
        #endif
    }

    public func startScanning() {
        if isSimulationEnabled {
            runSimulationScan()
            return
        }

        guard let central = centralManager, central.state == .poweredOn else {
            return
        }

        discoveredDevices.removeAll()
        isScanning = true

        // Use verified service UUID filter if known; nil allows discovery while protocol verification is pending
        let scanFilters: [CBUUID]? = nil
        central.scanForPeripherals(
            withServices: scanFilters,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    public func stopScanning() {
        isScanning = false
        centralManager?.stopScan()
        simulatedScanTimer?.cancel()
    }

    // MARK: - Simulation Mode (For Simulator & Offline Preview)
    private func runSimulationScan() {
        isScanning = true
        discoveredDevices.removeAll()

        simulatedScanTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isScanning else { return }
                if self.discoveredDevices.isEmpty {
                    let mockDevice = BLEDevice(
                        id: UUID(),
                        peripheral: nil,
                        name: "Shark Power V2 (Simulated)",
                        rssi: -58,
                        advertisedServices: [],
                        lastSeen: Date()
                    )
                    self.discoveredDevices.append(mockDevice)
                }
            }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEScanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.bluetoothState = central.state

        switch central.state {
        case .poweredOn:
            authorizationDenied = false
            if isScanning {
                startScanning()
            }
        case .unauthorized:
            authorizationDenied = true
            stopScanning()
        case .poweredOff, .resetting, .unsupported, .unknown:
            stopScanning()
        @unknown default:
            stopScanning()
        }
    }

    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? peripheral.name
            ?? "Unknown Peripheral"

        // Filter: match "Shark", "Power", "SUPRE", or include all during pairing probe
        let isSharkDevice = name.localizedCaseInsensitiveContains("Shark")
            || name.localizedCaseInsensitiveContains("Power")
            || name.localizedCaseInsensitiveContains("SUPRE")

        // Avoid duplicates, update RSSI if already present
        if let index = discoveredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
            discoveredDevices[index].rssi = RSSI.intValue
        } else if isSharkDevice || discoveredDevices.count < 10 {
            let services = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
            let device = BLEDevice(
                id: peripheral.identifier,
                peripheral: peripheral,
                name: name,
                rssi: RSSI.intValue,
                advertisedServices: services,
                lastSeen: Date()
            )
            discoveredDevices.append(device)
        }
    }
}
