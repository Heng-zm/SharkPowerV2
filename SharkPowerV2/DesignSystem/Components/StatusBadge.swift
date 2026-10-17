//
//  StatusBadge.swift
//  SharkPowerV2
//
//  Native iOS 26 Liquid Glass status pill badge with concentric breathing liquid indicator.
//

import SwiftUI

public struct StatusBadge: View {
    public let title: String
    public let color: Color
    public let isPulsing: Bool

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.7

    public init(title: String, color: Color, isPulsing: Bool = false) {
        self.title = title
        self.color = color
        self.isPulsing = isPulsing
    }

    public var body: some View {
        HStack(spacing: 7) {
            ZStack {
                if isPulsing {
                    Circle()
                        .stroke(color, lineWidth: 1.5)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                                pulseScale = 2.2
                                pulseOpacity = 0.0
                            }
                        }

                    Circle()
                        .fill(color.opacity(0.4))
                        .scaleEffect(pulseScale * 0.7)
                }

                // Core Luminescent Jewel Bead
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .shadow(color: color.opacity(0.8), radius: 4, x: 0, y: 0)
            }
            .frame(width: 12, height: 12)

            Text(title)
                .font(SharkTypography.badge)
                .tracking(0.5)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                Capsule()
                    .fill(color.opacity(0.14))
            }
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), color.opacity(0.40), Color.white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.20), radius: 6, x: 0, y: 2)
    }
}
