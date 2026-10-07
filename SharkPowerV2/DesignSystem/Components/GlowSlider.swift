//
//  GlowSlider.swift
//  SharkPowerV2
//
//  Automotive illuminated control slider with real-time glow and tactile drag.
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
            }

            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let clampedValue = max(0.0, min(1.0, value))
                let activeWidth = totalWidth * clampedValue

                ZStack(alignment: .leading) {
                    // Track Background
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(SharkTheme.backgroundTertiary)
                        .frame(height: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(SharkTheme.borderSubtle, lineWidth: 1)
                        )

                    // Active Glow Track
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tintColor.opacity(0.7), tintColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, activeWidth), height: 12)
                        .shadow(color: tintColor.opacity(0.4), radius: 6, x: 0, y: 0)

                    // Custom Automotive Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                        .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 2)
                        .shadow(color: tintColor.opacity(0.6), radius: 6, x: 0, y: 0)
                        .overlay(
                            Circle()
                                .stroke(tintColor, lineWidth: 2)
                        )
                        .offset(x: max(0, min(totalWidth - 22, activeWidth - 11)))
                }
                .frame(height: 24)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let progress = max(0.0, min(1.0, gesture.location.x / totalWidth))
                            value = progress

                            // Provide subtle haptic feedback every 10%
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
            .frame(height: 24)
        }
    }
}
