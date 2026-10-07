//
//  DevicesView.swift
//  SharkPowerV2
//
//  Dedicated automotive Bluetooth discovery and connection management screen.
//

import SwiftUI
import CoreBluetooth

public struct DevicesView: View {
    @StateObject private var viewModel = DevicesViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    if viewModel.isBluetoothPoweredOff {
                        bluetoothDisabledView
                    } else if viewModel.isBluetoothUnauthorized {
                        bluetoothUnauthorizedView
                    } else {
                        devicesContent
                    }
                }
            }
            .navigationTitle("Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isScanning {
                        ProgressView()
                            .tint(SharkTheme.neonCyan)
                    } else {
                        Button(action: {
                            viewModel.startScanning()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(SharkTheme.neonCyan)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.startScanning()
            }
        }
    }

    // MARK: - Main Devices Content
    private var devicesContent: some View {
        ScrollView {
            VStack(spacing: SharkSpacing.lg) {
                // Active Connection Card
                if case .connected(let name) = viewModel.connectionState {
                    connectedDeviceCard(name: name)
                } else if case .connecting(let id) = viewModel.connectionState {
                    connectingCard(id: id)
                } else if case .failed(let reason) = viewModel.connectionState {
                    connectionFailedCard(reason: reason)
                }

                // Discovered Peripherals Header & List
                VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                    HStack {
                        Text(viewModel.isScanning ? "SEARCHING FOR SHARK POWER..." : "DISCOVERED DEVICES")
                            .font(SharkTypography.caption)
                            .foregroundStyle(SharkTheme.textMuted)

                        Spacer()

                        Text("\(viewModel.discoveredDevices.count) FOUND")
                            .font(SharkTypography.telemetryMono)
                            .foregroundStyle(SharkTheme.neonCyan)
                    }
                    .padding(.horizontal, SharkSpacing.md)

                    if viewModel.discoveredDevices.isEmpty {
                        emptyDiscoveredCard
                    } else {
                        ForEach(viewModel.discoveredDevices) { device in
                            deviceRowCard(device: device)
                        }
                    }
                }

                // Simulation Mode Deck (For Testing / Simulator)
                AutomotiveCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Simulator Testing Mode")
                                .font(SharkTypography.headline)
                                .foregroundStyle(SharkTheme.textPrimary)

                            Text("Simulate Shark Power V2 peripheral discovery")
                                .font(SharkTypography.caption)
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { viewModel.isSimulationEnabled },
                            set: { _ in viewModel.toggleSimulation() }
                        ))
                        .tint(SharkTheme.neonCyan)
                    }
                }
                .padding(.horizontal, SharkSpacing.md)
                .padding(.bottom, 110)
            }
            .padding(.top, SharkSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Device Row Card
    private func deviceRowCard(device: BLEDevice) -> some View {
        AutomotiveCard {
            VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                HStack {
                    Image(systemName: "light.strip.2")
                        .font(.system(size: 20))
                        .foregroundStyle(SharkTheme.neonCyan)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(device.name)
                            .font(SharkTypography.headline)
                            .foregroundStyle(SharkTheme.textPrimary)

                        Text(device.id.uuidString.prefix(12) + "...")
                            .font(SharkTypography.telemetryMono)
                            .foregroundStyle(SharkTheme.textMuted)
                    }

                    Spacer()

                    Button("Connect") {
                        viewModel.connect(to: device)
                    }
                    .font(SharkTypography.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(SharkTheme.neonCyan))
                    .foregroundStyle(SharkTheme.backgroundPrimary)
                }

                Divider().background(SharkTheme.borderSubtle)

                // 10-Segment RSSI Signal Meter Bar
                HStack(spacing: 4) {
                    Text("Signal")
                        .font(SharkTypography.caption)
                        .foregroundStyle(SharkTheme.textSecondary)

                    Spacer()

                    signalMeterBar(strength: device.signalStrength)

                    Text("\(device.rssi) dBm")
                        .font(SharkTypography.telemetryMono)
                        .foregroundStyle(SharkTheme.textMuted)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, SharkSpacing.md)
    }

    // 10-segment graphical RSSI bar: ████████░░
    private func signalMeterBar(strength: Double) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<10) { index in
                let active = Double(index) / 10.0 < strength
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(active ? SharkTheme.neonCyan : SharkTheme.backgroundTertiary)
                    .frame(width: 8, height: 12)
            }
        }
    }

    // MARK: - Status Cards
    private func connectedDeviceCard(name: String) -> some View {
        AutomotiveCard(glowColor: SharkTheme.statusConnected) {
            VStack(spacing: SharkSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACTIVE HARDWARE")
                            .font(SharkTypography.badge)
                            .foregroundStyle(SharkTheme.statusConnected)

                        Text(name)
                            .font(SharkTypography.sectionTitle)
                            .foregroundStyle(SharkTheme.textPrimary)
                    }

                    Spacer()

                    StatusBadge(title: "CONNECTED", color: SharkTheme.statusConnected, isPulsing: true)
                }

                ActionButton(
                    title: "Disconnect",
                    systemImage: "power",
                    style: .secondary,
                    action: {
                        viewModel.disconnect()
                    }
                )
            }
        }
        .padding(.horizontal, SharkSpacing.md)
    }

    private func connectingCard(id: String) -> some View {
        AutomotiveCard(glowColor: SharkTheme.neonCyan) {
            HStack(spacing: SharkSpacing.md) {
                ProgressView().tint(SharkTheme.neonCyan)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connecting...")
                        .font(SharkTypography.headline)
                        .foregroundStyle(SharkTheme.textPrimary)
                    Text("Establishing GATT connection to \(id)")
                        .font(SharkTypography.caption)
                        .foregroundStyle(SharkTheme.textSecondary)
                }
                Spacer()
            }
        }
        .padding(.horizontal, SharkSpacing.md)
    }

    private func connectionFailedCard(reason: String) -> some View {
        AutomotiveCard(glowColor: SharkTheme.daytonaRed) {
            VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(SharkTheme.daytonaRed)
                    Text("Connection Lost / Failed")
                        .font(SharkTypography.headline)
                        .foregroundStyle(SharkTheme.textPrimary)
                }
                Text(reason)
                    .font(SharkTypography.caption)
                    .foregroundStyle(SharkTheme.textSecondary)

                ActionButton(
                    title: "Retry Scanning",
                    style: .primary(SharkTheme.neonCyan),
                    action: {
                        viewModel.startScanning()
                    }
                )
            }
        }
        .padding(.horizontal, SharkSpacing.md)
    }

    private var emptyDiscoveredCard: some View {
        AutomotiveCard {
            VStack(spacing: SharkSpacing.sm) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 32))
                    .foregroundStyle(SharkTheme.textMuted)

                Text("No Shark Power Devices in Range")
                    .font(SharkTypography.headline)
                    .foregroundStyle(SharkTheme.textPrimary)

                Text("Ensure LED controller has 12V/5V power connected and Bluetooth is turned on.")
                    .font(SharkTypography.caption)
                    .foregroundStyle(SharkTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SharkSpacing.md)
        }
        .padding(.horizontal, SharkSpacing.md)
    }

    // MARK: - Bluetooth State Banners
    private var bluetoothDisabledView: some View {
        VStack(spacing: SharkSpacing.md) {
            Image(systemName: "bolt.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(SharkTheme.daytonaRed)

            Text("Bluetooth is Off")
                .font(SharkTypography.displayTitle)
                .foregroundStyle(SharkTheme.textPrimary)

            Text("Please enable Bluetooth in iOS Settings or Control Center to pair your Shark Power V2.")
                .font(SharkTypography.body)
                .foregroundStyle(SharkTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SharkSpacing.xl)
        }
        .padding()
    }

    private var bluetoothUnauthorizedView: some View {
        VStack(spacing: SharkSpacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(SharkTheme.cyberAmber)

            Text("Bluetooth Permission Required")
                .font(SharkTypography.displayTitle)
                .foregroundStyle(SharkTheme.textPrimary)

            Text("Shark Power V2 requires Bluetooth permission to communicate with your LED lighting hardware.")
                .font(SharkTypography.body)
                .foregroundStyle(SharkTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SharkSpacing.xl)
        }
        .padding()
    }
}
