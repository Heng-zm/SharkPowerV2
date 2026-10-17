//
//  GlowSlider.swift
//  SharkPowerV2
//
//  Native iOS 26 Liquid Glass control slider with luminous liquid fill and prismatic optic lens thumb.
//

import SwiftUI

public struct GlowSlider: View {
    public let title: String
    public let systemImage: String
    @Binding public var value: Double // Normalized 0.0 ... 1.0
    public let tintColor: Color
    public let valueFormatter: (Double) -> String

    @State private var isDragging: Bool = false
    @State private var lastFeedbackTick: Int = 0

    public init(
        title: String,
        systemImage: String,
        value: Binding<Double>,
        tintColor: Color = SharkTheme.neonCyan,
        valueFormatter: @escaping (Double) -> String = { "\(Int($0 * 100))%" }
    ) {
        self.title = title
        self.systemImage = systemImage
        self._value = value
        self.tintColor = tintColor
        self.valueFormatter = valueFormatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SharkSpacing.xs) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(SharkTypography.caption)
                    .foregroundStyle(SharkTheme.textSecondary)

                Spacer()

                Text(valueFormatter(value))
                    .font(SharkTypography.telemetryMono)
                    .foregroundStyle(tintColor)
                    .shadow(color: tintColor.opacity(0.5), radius: 6, x: 0, y: 0)
            }

            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let clampedValue = max(0.0, min(1.0, value))
                let activeWidth = totalWidth * clampedValue
                let thumbDiameter: CGFloat = 24

                ZStack(alignment: .leading) {
                    // 1. Frosted Glass Track Background
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(SharkTheme.glassSurfaceBase)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.25), Color.black.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    // 2. Active Liquid Illumination Conduit
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tintColor.opacity(0.70), tintColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(14, activeWidth), height: 14)
                        .overlay(
                            // Liquid Specular Highlight Line
                            VStack {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.40), Color.white.opacity(0.0)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 6)
                                Spacer()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        )
                        .shadow(color: tintColor.opacity(0.55), radius: 8, x: 0, y: 0)

                    // 3. 3D Liquid Glass Optic Lens Thumb
                    ZStack {
                        // Ambient Caustic Halo
                        Circle()
                            .fill(tintColor.opacity(isDragging ? 0.8 : 0.5))
                            .frame(width: thumbDiameter + 10, height: thumbDiameter + 10)
                            .blur(radius: 6)

                        // Translucent Glass Lens Outer Body
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: thumbDiameter, height: thumbDiameter)
                            .overlay(
                                Circle()
                                    .fill(SharkTheme.glassSurfaceElevated)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.white, tintColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )

                        // Pure White Optic Core Bead
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                    }
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isDragging)
                    .offset(x: max(0, min(totalWidth - thumbDiameter, activeWidth - (thumbDiameter / 2.0))))
                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .frame(height: 28)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let progress = max(0.0, min(1.0, gesture.location.x / totalWidth))
                            value = progress

                            // Provide subtle tactile tick every 10%
                            let currentTick = Int(progress * 10)
                            if currentTick != lastFeedbackTick {
                                lastFeedbackTick = currentTick
                                Haptics.shared.selectionChanged()
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            Haptics.shared.lightImpact()
                        }
                )
            }
            .frame(height: 28)
        }
    }
}
