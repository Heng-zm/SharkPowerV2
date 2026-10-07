//
//  DiagnosticsView.swift
//  SharkPowerV2
//
//  In-depth automotive engineering diagnostic screen for field testing and protocol reverse engineering.
//

import SwiftUI

public struct DiagnosticsView: View {
    @StateObject private var viewModel = DiagnosticsViewModel()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SharkSpacing.md) {
                        // Protocol Verification Status Banner
                        AutomotiveCard(glowColor: SharkTheme.cyberAmber) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .foregroundStyle(SharkTheme.cyberAmber)
                                    Text("PROTOCOL VERIFICATION STATUS")
                                        .font(SharkTypography.badge)
                                        .foregroundStyle(SharkTheme.cyberAmber)
                                    Spacer()
                                    Text("TBD")
                                        .font(SharkTypography.badge)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(SharkTheme.cyberAmber.opacity(0.2)))
                                        .foregroundStyle(SharkTheme.cyberAmber)
                                }

                                Text(viewModel.protocolStatusText)
                                    .font(SharkTypography.subheadline)
                                    .foregroundStyle(SharkTheme.textPrimary)

                                Text("In accordance with Rule 1 and Rule 2, hardware packet transmission remains blocked until raw byte opcodes are captured from real Shark Power V2 hardware.")
                                    .font(SharkTypography.caption)
                                    .foregroundStyle(SharkTheme.textSecondary)
                            }
                        }

                        // Simulation Status Banner
                        if viewModel.isSimulationActive {
                            AutomotiveCard(glowColor: SharkTheme.neonCyan) {
                                HStack {
                                    Image(systemName: "cpu")
                                        .foregroundStyle(SharkTheme.neonCyan)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("SIMULATION MODE ACTIVE")
                                            .font(SharkTypography.badge)
                                            .foregroundStyle(SharkTheme.neonCyan)
                                        Text("Operating with simulated peripheral. Does not represent hardware verification.")
                                            .font(SharkTypography.caption)
                                            .foregroundStyle(SharkTheme.textSecondary)
                                    }
                                    Spacer()
                                }
                            }
                        }

                        // Bluetooth Radio Telemetry
                        AutomotiveCard {
                            VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                                Text("COREBLUETOOTH STATUS")
                                    .font(SharkTypography.caption)
                                    .foregroundStyle(SharkTheme.textMuted)

                                diagnosticRow(label: "Central State", value: viewModel.bluetoothStateString)
                                diagnosticRow(label: "Scanner Active", value: viewModel.isScanning ? "Scanning (Active)" : "Idle")
                                diagnosticRow(label: "Connection State", value: viewModel.connectionStateString)
                                diagnosticRow(label: "Active Peripheral", value: viewModel.activeDeviceId)
                                diagnosticRow(label: "Signal RSSI", value: viewModel.rssiString)
                            }
                        }

                        // GATT Discovery Telemetry
                        AutomotiveCard {
                            VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                                Text("GATT SERVICE DISCOVERY")
                                    .font(SharkTypography.caption)
                                    .foregroundStyle(SharkTheme.textMuted)

                                if viewModel.discoveredServices.isEmpty {
                                    Text("No services discovered yet. Connect to hardware to inspect.")
                                        .font(SharkTypography.caption)
                                        .foregroundStyle(SharkTheme.textSecondary)
                                } else {
                                    ForEach(viewModel.discoveredServices, id: \.self) { service in
                                        Text("Service: \(service)")
                                            .font(SharkTypography.telemetryMono)
                                            .foregroundStyle(SharkTheme.textPrimary)
                                    }
                                }

                                Divider().background(SharkTheme.borderSubtle)

                                Text("CHARACTERISTICS")
                                    .font(SharkTypography.caption)
                                    .foregroundStyle(SharkTheme.textMuted)

                                if viewModel.discoveredCharacteristics.isEmpty {
                                    Text("No characteristics discovered yet.")
                                        .font(SharkTypography.caption)
                                        .foregroundStyle(SharkTheme.textSecondary)
                                } else {
                                    ForEach(viewModel.discoveredCharacteristics, id: \.self) { char in
                                        Text(char)
                                            .font(SharkTypography.telemetryMono)
                                            .foregroundStyle(SharkTheme.textSecondary)
                                    }
                                }
                            }
                        }

                        // Event Log Stream
                        AutomotiveCard {
                            VStack(alignment: .leading, spacing: SharkSpacing.xs) {
                                HStack {
                                    Text("LIVE EVENT STREAM")
                                        .font(SharkTypography.caption)
                                        .foregroundStyle(SharkTheme.textMuted)
                                    Spacer()
                                    ShareLink(item: viewModel.eventLogs.joined(separator: "\n")) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.caption)
                                            .foregroundStyle(SharkTheme.neonCyan)
                                    }
                                }

                                ScrollView {
                                    VStack(alignment: .leading, spacing: 3) {
                                        ForEach(viewModel.eventLogs.indices, id: \.self) { idx in
                                            Text(viewModel.eventLogs[idx])
                                                .font(SharkTypography.telemetryMono)
                                                .foregroundStyle(SharkTheme.textSecondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .frame(height: 180)
                            }
                        }
                    }
                    .padding(SharkSpacing.md)
                }
            }
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(SharkTheme.neonCyan)
                }
            }
        }
    }

    private func diagnosticRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SharkTypography.body)
                .foregroundStyle(SharkTheme.textSecondary)
            Spacer()
            Text(value)
                .font(SharkTypography.telemetryMono)
                .foregroundStyle(SharkTheme.textPrimary)
        }
    }
}
