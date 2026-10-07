//
//  SettingsView.swift
//  SharkPowerV2
//
//  Clean iOS automotive settings screen with diagnostics console and GATT inspector.
//

import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showLogsSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                List {
                    // MARK: - Device Section
                    Section("Hardware Device") {
                        HStack {
                            Text("Connected Device")
                            Spacer()
                            Text(viewModel.connectedDeviceName)
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        Toggle("Auto-Reconnect", isOn: $viewModel.autoReconnect)
                            .tint(SharkTheme.neonCyan)

                        if viewModel.connectedDeviceName != "None" {
                            Button("Forget Device", role: .destructive) {
                                viewModel.forgetCurrentDevice()
                            }
                        }
                    }
                    .listRowBackground(SharkTheme.backgroundSecondary)

                    // MARK: - Appearance Section
                    Section("Appearance") {
                        Picker("Theme", selection: $viewModel.appearanceMode) {
                            Text("Dark Cockpit").tag("Dark")
                            Text("Light").tag("Light")
                            Text("System").tag("System")
                        }
                        .pickerStyle(.menu)
                    }
                    .listRowBackground(SharkTheme.backgroundSecondary)

                    // MARK: - Animation & Feedback
                    Section("Engine & Haptics") {
                        Toggle("60 FPS Preview Engine", isOn: $viewModel.highFramerateEnabled)
                            .tint(SharkTheme.neonCyan)

                        Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedbackEnabled)
                            .tint(SharkTheme.neonCyan)
                    }
                    .listRowBackground(SharkTheme.backgroundSecondary)

                    // MARK: - Diagnostics & GATT Section
                    Section("Diagnostics & Verification") {
                        HStack {
                            Text("Protocol Status")
                            Spacer()
                            Text(viewModel.protocolVerificationStatus)
                                .font(SharkTypography.caption)
                                .foregroundStyle(SharkTheme.cyberAmber)
                        }

                        HStack {
                            Text("GATT Services Discovered")
                            Spacer()
                            Text("\(viewModel.discoveredServicesCount)")
                                .font(SharkTypography.telemetryMono)
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        HStack {
                            Text("GATT Characteristics")
                            Spacer()
                            Text("\(viewModel.discoveredCharacteristicsCount)")
                                .font(SharkTypography.telemetryMono)
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        Button(action: {
                            showLogsSheet = true
                        }) {
                            HStack {
                                Text("View Connection Logs")
                                    .foregroundStyle(SharkTheme.neonCyan)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(SharkTheme.textMuted)
                            }
                        }
                    }
                    .listRowBackground(SharkTheme.backgroundSecondary)

                    // MARK: - About Section
                    Section("About") {
                        HStack {
                            Text("Application")
                            Spacer()
                            Text("Shark Power V2 Rebuild")
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0 (Build 1)")
                                .font(SharkTypography.telemetryMono)
                                .foregroundStyle(SharkTheme.textSecondary)
                        }

                        HStack {
                            Text("Engine")
                            Spacer()
                            Text("SwiftUI Canvas + TimelineView")
                                .foregroundStyle(SharkTheme.textSecondary)
                        }
                    }
                    .listRowBackground(SharkTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLogsSheet) {
                logsConsoleSheet
            }
        }
    }

    private var logsConsoleSheet: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.eventLogs.indices, id: \.self) { idx in
                            Text(viewModel.eventLogs[idx])
                                .font(SharkTypography.telemetryMono)
                                .foregroundStyle(SharkTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(SharkSpacing.md)
                }
            }
            .navigationTitle("Diagnostic Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: viewModel.eventLogs.joined(separator: "\n")) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(SharkTheme.neonCyan)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showLogsSheet = false
                    }
                    .foregroundStyle(SharkTheme.neonCyan)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
