//
//  ColorPickerSheet.swift
//  SharkPowerV2
//
//  iOS bottom sheet presenting curated automotive swatches and full RGB picker.
//

import SwiftUI

public struct ColorPreset: Identifiable {
    public let id = UUID()
    public let name: String
    public let color: Color

    public static let automotivePalettes: [ColorPreset] = [
        ColorPreset(name: "Laser Cyan", color: SharkTheme.neonCyan),
        ColorPreset(name: "Daytona Red", color: SharkTheme.daytonaRed),
        ColorPreset(name: "Cyber Amber", color: SharkTheme.cyberAmber),
        ColorPreset(name: "Racing Blue", color: SharkTheme.electricBlue),
        ColorPreset(name: "Acid Green", color: SharkTheme.acidGreen),
        ColorPreset(name: "Ultra Violet", color: SharkTheme.ultraViolet),
        ColorPreset(name: "Xenon White", color: SharkTheme.pureWhite),
        ColorPreset(name: "Hyper Yellow", color: Color(red: 1.0, green: 0.9, blue: 0.1)),
        ColorPreset(name: "Tangerine", color: Color(red: 1.0, green: 0.45, blue: 0.05))
    ]
}

public struct ColorPickerSheet: View {
    @Binding public var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    public init(selectedColor: Binding<Color>) {
        self._selectedColor = selectedColor
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundSecondary.ignoresSafeArea()

                VStack(spacing: SharkSpacing.lg) {
                    // Header Color Banner Preview
                    HStack(spacing: SharkSpacing.md) {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                            .shadow(color: selectedColor.opacity(0.5), radius: 10, x: 0, y: 0)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Active Color Beam")
                                .font(SharkTypography.headline)
                                .foregroundStyle(SharkTheme.textPrimary)

                            Text(selectedColor.toHex())
                                .font(SharkTypography.telemetryMono)
                                .foregroundStyle(selectedColor)
                        }

                        Spacer()

                        ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                            .labelsHidden()
                            .scaleEffect(1.2)
                    }
                    .padding(SharkSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SharkSpacing.Radius.medium, style: .continuous)
                            .fill(SharkTheme.backgroundTertiary)
                    )

                    // Curated Automotive Palette Grid
                    VStack(alignment: .leading, spacing: SharkSpacing.sm) {
                        Text("AUTOMOTIVE PALETTE")
                            .font(SharkTypography.caption)
                            .foregroundStyle(SharkTheme.textMuted)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))], spacing: 14) {
                            ForEach(ColorPreset.automotivePalettes) { preset in
                                Button(action: {
                                    Haptics.shared.selectionChanged()
                                    withAnimation(.smooth) {
                                        selectedColor = preset.color
                                    }
                                }) {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(preset.color)
                                                .frame(width: 42, height: 42)
                                                .shadow(color: preset.color.opacity(0.4), radius: 6, x: 0, y: 0)

                                            if selectedColor.toHex() == preset.color.toHex() {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(Color.black)
                                            }
                                        }

                                        Text(preset.name)
                                            .font(SharkTypography.badge)
                                            .foregroundStyle(SharkTheme.textSecondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    // Done Button
                    ActionButton(
                        title: "Done",
                        style: .primary(selectedColor),
                        action: {
                            Haptics.shared.lightImpact()
                            dismiss()
                        }
                    )
                }
                .padding(SharkSpacing.lg)
            }
            .navigationTitle("Beam Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(SharkTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
