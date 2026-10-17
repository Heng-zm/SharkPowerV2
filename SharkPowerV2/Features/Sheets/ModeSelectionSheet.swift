//
//  ModeSelectionSheet.swift
//  SharkPowerV2
//
//  iOS bottom sheet presenting all continuous lighting animation modes with live mini-previews.
//

import SwiftUI

public struct ModeSelectionSheet: View {
    @Binding public var selectedMode: LEDMode
    public let parameters: LEDAnimationParameters
    @Environment(\.dismiss) private var dismiss

    public init(selectedMode: Binding<LEDMode>, parameters: LEDAnimationParameters) {
        self._selectedMode = selectedMode
        self.parameters = parameters
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidAmbientBackground(accentColor: parameters.color)

                ScrollView {
                    VStack(spacing: SharkSpacing.md) {
                        ForEach(LEDMode.allCases) { mode in
                            let isSelected = (selectedMode == mode)

                            Button(action: {
                                Haptics.shared.selectionChanged()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selectedMode = mode
                                }
                            }) {
                                VStack(alignment: .leading, spacing: SharkSpacing.xs) {
                                    HStack {
                                        Image(systemName: mode.iconName)
                                            .font(SharkTypography.headline)
                                            .foregroundStyle(isSelected ? parameters.color : SharkTheme.textSecondary)

                                        Text(mode.rawValue)
                                            .font(SharkTypography.headline)
                                            .foregroundStyle(SharkTheme.textPrimary)

                                        Spacer()

                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(parameters.color)
                                                .shadow(color: parameters.color.opacity(0.6), radius: 6, x: 0, y: 0)
                                        }
                                    }

                                    Text(mode.description)
                                        .font(SharkTypography.caption)
                                        .foregroundStyle(SharkTheme.textSecondary)
                                        .multilineTextAlignment(.leading)

                                    // Mini continuous light strip preview for this specific mode
                                    LEDPreviewView(
                                        mode: mode,
                                        parameters: parameters,
                                        isInteractive: false
                                    )
                                    .frame(height: 80)
                                    .padding(.top, 4)
                                }
                                .padding(SharkSpacing.md)
                                .liquidGlassSurface(
                                    cornerRadius: SharkSpacing.Radius.glassCard,
                                    glowColor: isSelected ? parameters.color : nil
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(SharkSpacing.md)
                }
            }
            .navigationTitle("Lighting Modes")
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
