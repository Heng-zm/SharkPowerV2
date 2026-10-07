//
//  FullScreenPreviewView.swift
//  SharkPowerV2
//
//  Immersive cockpit full-screen LED preview experience with rapid telemetry tuning.
//

import SwiftUI

public struct FullScreenPreviewView: View {
    @Binding public var mode: LEDMode
    @Binding public var parameters: LEDAnimationParameters
    public let onApply: () -> Void
    public let isApplying: Bool
    @Environment(\.dismiss) private var dismiss

    public init(
        mode: Binding<LEDMode>,
        parameters: Binding<LEDAnimationParameters>,
        isApplying: Bool = false,
        onApply: @escaping () -> Void
    ) {
        self._mode = mode
        self._parameters = parameters
        self.isApplying = isApplying
        self.onApply = onApply
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                SharkTheme.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: SharkSpacing.xl) {
                    // Top Telemetry Header
                    VStack(spacing: 4) {
                        Text("SHARK POWER V2")
                            .font(SharkTypography.telemetryMono)
                            .tracking(3)
                            .foregroundStyle(SharkTheme.textMuted)

                        Text(mode.rawValue.uppercased())
                            .font(SharkTypography.displayTitle)
                            .foregroundStyle(parameters.color)

                        Text(mode.description)
                            .font(SharkTypography.caption)
                            .foregroundStyle(SharkTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, SharkSpacing.md)

                    Spacer()

                    // Massive High-Definition Continuous Light Bar
                    VStack(spacing: SharkSpacing.md) {
                        TimelineView(.animation) { timeline in
                            let activeAnim = LEDAnimationFactory.animation(for: mode)

                            Canvas { context, size in
                                LEDCanvasRenderer.render(
                                    context: &context,
                                    size: size,
                                    animation: activeAnim,
                                    time: timeline.date.timeIntervalSinceReferenceDate,
                                    parameters: parameters
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                        }
                    }
                    .padding(.horizontal, SharkSpacing.lg)

                    Spacer()

                    // Tuning Controls Deck
                    AutomotiveCard(glowColor: parameters.color) {
                        VStack(spacing: SharkSpacing.md) {
                            // Mode Pill Selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(LEDMode.allCases) { m in
                                        Button(action: {
                                            Haptics.shared.selectionChanged()
                                            withAnimation(.smooth) {
                                                mode = m
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: m.iconName)
                                                Text(m.rawValue)
                                            }
                                            .font(SharkTypography.subheadline)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(mode == m ? parameters.color : SharkTheme.backgroundTertiary)
                                            )
                                            .foregroundStyle(mode == m ? SharkTheme.backgroundPrimary : SharkTheme.textPrimary)
                                        }
                                    }
                                }
                            }

                            Divider().background(SharkTheme.borderSubtle)

                            // Speed & Brightness Sliders
                            GlowSlider(
                                title: "Slide Speed",
                                systemImage: "gauge.with.dots.needle.50percent",
                                value: $parameters.speed,
                                tintColor: parameters.color
                            )

                            GlowSlider(
                                title: "Luminous Intensity",
                                systemImage: "sun.max.fill",
                                value: $parameters.brightness,
                                tintColor: parameters.color
                            )

                            // Apply Button
                            ActionButton(
                                title: isApplying ? "APPLYING..." : "APPLY TO DEVICE",
                                systemImage: "antenna.radiowaves.left.and.right",
                                style: .primary(parameters.color),
                                isLoading: isApplying,
                                action: {
                                    Haptics.shared.heavyImpact()
                                    onApply()
                                }
                            )
                            .padding(.top, SharkSpacing.xs)
                        }
                    }
                    .padding(.horizontal, SharkSpacing.md)
                    .padding(.bottom, SharkSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(SharkTypography.headline)
                    .foregroundStyle(SharkTheme.neonCyan)
                }
            }
        }
    }
}
