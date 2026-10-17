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
                LiquidAmbientBackground(accentColor: parameters.color)

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
                            .shadow(color: parameters.color.opacity(0.6), radius: 10, x: 0, y: 0)

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
                                        let isSelected = (mode == m)
                                        Button(action: {
                                            Haptics.shared.selectionChanged()
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
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
                                                ZStack {
                                                    if isSelected {
                                                        LinearGradient(
                                                            colors: [parameters.color, parameters.color.opacity(0.85)],
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
                                                            ? LinearGradient(colors: [Color.white.opacity(0.5), parameters.color], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                            : SharkTheme.glassSpecularBorder(),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .foregroundStyle(isSelected ? SharkTheme.backgroundPrimary : SharkTheme.textPrimary)
                                        }
                                        .buttonStyle(.plain)
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
