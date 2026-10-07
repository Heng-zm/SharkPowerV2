//
//  StatusBadge.swift
//  SharkPowerV2
//
//  Automotive connection status pill badge with pulsing indicator.
//

import SwiftUI

public struct StatusBadge: View {
    public let title: String
    public let color: Color
    public let isPulsing: Bool

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6

    public init(title: String, color: Color, isPulsing: Bool = false) {
        self.title = title
        self.color = color
        self.isPulsing = isPulsing
    }

    public var body: some View {
        HStack(spacing: 6) {
            ZStack {
                if isPulsing {
                    Circle()
                        .fill(color)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                pulseScale = 1.6
                                pulseOpacity = 0.0
                            }
                        }
                }
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
            }
            .frame(width: 10, height: 10)

            Text(title)
                .font(SharkTypography.badge)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
