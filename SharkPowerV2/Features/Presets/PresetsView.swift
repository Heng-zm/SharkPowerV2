//
//  PresetsView.swift
//  SharkPowerV2
//
//  Persistent automotive lighting presets with live continuous strip previews.
//

import SwiftUI
import SwiftData

public struct PresetsView: View {
    @Query(sort: \SavedPreset.createdAt, order: .reverse) private var presets: [SavedPreset]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = PresetsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SharkSpacing.md) {
                        if presets.isEmpty {
                            emptyPresetsView
                        } else {
                            ForEach(presets) { preset in
                                presetCard(preset: preset)
                            }
                        }
                    }
                    .padding(.horizontal, SharkSpacing.md)
                    .padding(.top, SharkSpacing.md)
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Presets")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Rename Preset", isPresented: Binding(
                get: { viewModel.selectedPresetForEdit != nil },
                set: { if !$0 { viewModel.selectedPresetForEdit = nil } }
            )) {
                TextField("Preset Name", text: $viewModel.editName)
                Button("Save") {
                    if let target = viewModel.selectedPresetForEdit {
                        target.name = viewModel.editName
                        try? modelContext.save()
                        Haptics.shared.notifySuccess()
                    }
                    viewModel.selectedPresetForEdit = nil
                }
                Button("Cancel", role: .cancel) {
                    viewModel.selectedPresetForEdit = nil
                }
            }
        }
    }

    private func presetCard(preset: SavedPreset) -> some View {
        AutomotiveCard(glowColor: preset.color) {
            VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                HStack {
                    Circle()
                        .fill(preset.color)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))

                    Text(preset.name)
                        .font(SharkTypography.headline)
                        .foregroundStyle(SharkTheme.textPrimary)

                    Spacer()

                    Text(preset.mode.uppercased())
                        .font(SharkTypography.badge)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(preset.color.opacity(0.15)))
                        .foregroundStyle(preset.color)
                }

                // Mini live continuous light bar preview for this preset
                LEDPreviewView(
                    mode: preset.ledMode,
                    parameters: preset.animationParameters,
                    isInteractive: false
                )
                .frame(height: 70)

                HStack {
                    HStack(spacing: 12) {
                        Label("\(Int(preset.brightness * 100))%", systemImage: "sun.max.fill")
                            .font(SharkTypography.telemetryMono)
                            .foregroundStyle(SharkTheme.textSecondary)

                        Label("\(Int(preset.speed * 100))%", systemImage: "gauge.with.dots.needle.50percent")
                            .font(SharkTypography.telemetryMono)
                            .foregroundStyle(SharkTheme.textSecondary)
                    }

                    Spacer()

                    // Quick Actions
                    Menu {
                        Button("Rename") {
                            viewModel.selectedPresetForEdit = preset
                            viewModel.editName = preset.name
                        }
                        Button(role: .destructive) {
                            viewModel.deletePreset(preset, context: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(SharkTheme.textSecondary)
                            .padding(6)
                    }

                    Button("Apply") {
                        viewModel.applyPreset(preset)
                    }
                    .font(SharkTypography.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(preset.color))
                    .foregroundStyle(SharkTheme.backgroundPrimary)
                }
            }
        }
    }

    private var emptyPresetsView: some View {
        AutomotiveCard {
            VStack(spacing: SharkSpacing.sm) {
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 32))
                    .foregroundStyle(SharkTheme.textMuted)

                Text("No Saved Presets")
                    .font(SharkTypography.headline)
                    .foregroundStyle(SharkTheme.textPrimary)

                Text("Configure your preferred pattern and color on the Dashboard, then tap bookmark to save.")
                    .font(SharkTypography.caption)
                    .foregroundStyle(SharkTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SharkSpacing.md)
        }
    }
}
