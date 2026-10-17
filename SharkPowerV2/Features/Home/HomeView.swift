//
//  HomeView.swift
//  SharkPowerV2
//
//  Automotive cockpit dashboard featuring live continuous sequential LED light preview.
//

import SwiftUI
import SwiftData

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground(accentColor: viewModel.parameters.color)

                ScrollView {
                    VStack(spacing: SharkSpacing.md) {
                        // Top Telemetry Header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SHARK POWER V2")
                                    .font(SharkTypography.telemetryMono)
                                    .tracking(2)
                                    .foregroundStyle(SharkTheme.textMuted)

                                Text("Cockpit Lighting")
                                    .font(SharkTypography.sectionTitle)
                                    .foregroundStyle(SharkTheme.textPrimary)
                            }

                            Spacer()

                            // Connection Status Pill
                            StatusBadge(
                                title: viewModel.isConnected ? "CONNECTED" : "OFFLINE",
                                color: viewModel.isConnected ? SharkTheme.statusConnected : SharkTheme.statusDisconnected,
                                isPulsing: viewModel.isConnected
                            )
                        }
                        .padding(.horizontal, SharkSpacing.md)
                        .padding(.top, SharkSpacing.xs)

                        // 1. HERO: Live Continuous Sequential LED Preview
                        LEDPreviewView(
                            mode: viewModel.selectedMode,
                            parameters: viewModel.parameters,
                            isInteractive: true,
                            onExpandTapped: {
                                viewModel.showFullScreenPreview = true
                            }
                        )
                        .padding(.horizontal, SharkSpacing.md)

                        // 2. Quick Mode Selector Bar
                        VStack(alignment: .leading, spacing: SharkSpacing.xs) {
                            HStack {
                                Text("LIGHTING PATTERN")
                                    .font(SharkTypography.caption)
                                    .foregroundStyle(SharkTheme.textMuted)

                                Spacer()

                                Button("See All") {
                                    viewModel.showModeSheet = true
                                }
                                .font(SharkTypography.caption)
                                .foregroundStyle(viewModel.parameters.color)
                            }
                            .padding(.horizontal, SharkSpacing.md)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(LEDMode.allCases) { mode in
                                        let isSelected = viewModel.selectedMode == mode
                                        Button(action: {
                                            Haptics.shared.selectionChanged()
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                viewModel.selectedMode = mode
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: mode.iconName)
                                                Text(mode.rawValue)
                                            }
                                            .font(SharkTypography.subheadline)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                ZStack {
                                                    if isSelected {
                                                        LinearGradient(
                                                            colors: [viewModel.parameters.color, viewModel.parameters.color.opacity(0.85)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    } else {
                                                        Capsule().fill(.ultraThinMaterial)
                                                        Capsule().fill(SharkTheme.glassSurfaceBase)
                                                    }
                                                }
                                                .clipShape(Capsule())
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(
                                                        isSelected
                                                            ? LinearGradient(colors: [Color.white.opacity(0.55), viewModel.parameters.color], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                            : SharkTheme.glassSpecularBorder(),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .shadow(
                                                color: isSelected ? viewModel.parameters.color.opacity(0.35) : Color.black.opacity(0.2),
                                                radius: isSelected ? 8 : 4,
                                                x: 0,
                                                y: 2
                                            )
                                            .foregroundStyle(isSelected ? SharkTheme.backgroundPrimary : SharkTheme.textPrimary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, SharkSpacing.md)
                            }
                        }

                        // 3. Sliders Deck (Speed & Brightness)
                        AutomotiveCard(glowColor: viewModel.parameters.color) {
                            VStack(spacing: SharkSpacing.md) {
                                GlowSlider(
                                    title: "Slide Travel Speed",
                                    systemImage: "gauge.with.dots.needle.50percent",
                                    value: $viewModel.draftState.parameters.speed,
                                    tintColor: viewModel.parameters.color
                                )

                                Divider().background(SharkTheme.borderSubtle)

                                GlowSlider(
                                    title: "Luminous Brightness",
                                    systemImage: "sun.max.fill",
                                    value: $viewModel.draftState.parameters.brightness,
                                    tintColor: viewModel.parameters.color
                                )
                            }
                        }
                        .padding(.horizontal, SharkSpacing.md)

                        // 4. Action Controls: [ Customize / Color ] & [ Save Preset ]
                        VStack(spacing: SharkSpacing.sm) {
                            HStack(spacing: SharkSpacing.sm) {
                                // Color / Customize Button
                                Button(action: {
                                    Haptics.shared.lightImpact()
                                    viewModel.showColorPicker = true
                                }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(viewModel.parameters.color)
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                                            .shadow(color: viewModel.parameters.color.opacity(0.7), radius: 6, x: 0, y: 0)

                                        Text("Beam Color")
                                            .font(SharkTypography.headline)
                                            .foregroundStyle(SharkTheme.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .liquidGlassSurface(cornerRadius: SharkSpacing.Radius.glassButton, glowColor: viewModel.parameters.color.opacity(0.3))
                                }
                                .buttonStyle(.plain)

                                // Save Preset Button
                                Button(action: {
                                    Haptics.shared.lightImpact()
                                    viewModel.presetNameInput = "\(viewModel.selectedMode.rawValue) \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
                                    viewModel.showSavePresetSheet = true
                                }) {
                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(SharkTheme.textPrimary)
                                        .frame(width: 50, height: 50)
                                        .liquidGlassSurface(cornerRadius: SharkSpacing.Radius.glassButton)
                                }
                                .buttonStyle(.plain)
                            }

                            // Primary Apply Button
                            applyButtonView
                        }
                        .padding(.horizontal, SharkSpacing.md)
                        .padding(.bottom, 110)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showColorPicker) {
                ColorPickerSheet(selectedColor: $viewModel.draftState.parameters.color)
            }
            .sheet(isPresented: $viewModel.showModeSheet) {
                ModeSelectionSheet(selectedMode: $viewModel.draftState.mode, parameters: viewModel.parameters)
            }
            .fullScreenCover(isPresented: $viewModel.showFullScreenPreview) {
                FullScreenPreviewView(
                    mode: $viewModel.draftState.mode,
                    parameters: $viewModel.draftState.parameters,
                    isApplying: viewModel.applyState.isApplying,
                    onApply: {
                        viewModel.applyToDevice()
                    }
                )
            }
            .alert("Save as Preset", isPresented: $viewModel.showSavePresetSheet) {
                TextField("Preset Name", text: $viewModel.presetNameInput)
                Button("Save") {
                    let preset = SavedPreset(
                        name: viewModel.presetNameInput.isEmpty ? "My Preset" : viewModel.presetNameInput,
                        mode: viewModel.selectedMode.rawValue,
                        colorHex: viewModel.parameters.color.toHex(),
                        brightness: viewModel.parameters.brightness,
                        speed: viewModel.parameters.speed
                    )
                    modelContext.insert(preset)
                    try? modelContext.save()
                    Haptics.shared.notifySuccess()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var applyButtonView: some View {
        switch viewModel.applyState {
        case .idle:
            ActionButton(
                title: "APPLY TO DEVICE",
                systemImage: "antenna.radiowaves.left.and.right",
                style: .primary(viewModel.parameters.color),
                action: {
                    viewModel.applyToDevice()
                }
            )
        case .applying:
            ActionButton(
                title: "Applying to Shark Power...",
                style: .primary(viewModel.parameters.color),
                isLoading: true,
                action: {}
            )
        case .applied:
            ActionButton(
                title: "Applied Successfully",
                systemImage: "checkmark.circle.fill",
                style: .primary(SharkTheme.statusConnected),
                action: {}
            )
        case .failed(let reason):
            VStack(spacing: 6) {
                ActionButton(
                    title: "Unable to Apply — Try Again",
                    systemImage: "exclamationmark.triangle.fill",
                    style: .danger,
                    action: {
                        viewModel.applyToDevice()
                    }
                )
                Text(reason)
                    .font(SharkTypography.caption)
                    .foregroundStyle(SharkTheme.daytonaRed)
            }
        }
    }
}
