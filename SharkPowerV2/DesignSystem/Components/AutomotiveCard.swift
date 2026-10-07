//
//  AutomotiveCard.swift
//  SharkPowerV2
//
//  Premium automotive cockpit card surface with subtle metallic bevel & glow.
//

import SwiftUI

public struct AutomotiveCard<Content: View>: View {
    private let content: Content
    private let glowColor: Color?
    private let cornerRadius: CGFloat

    public init(
        glowColor: Color? = nil,
        cornerRadius: CGFloat = SharkSpacing.Radius.large,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.glowColor = glowColor
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        content
            .padding(SharkSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(SharkTheme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        (glowColor ?? SharkTheme.borderGlow).opacity(0.35),
                                        SharkTheme.borderSubtle
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: (glowColor ?? Color.black).opacity(glowColor != nil ? 0.15 : 0.4), radius: 12, x: 0, y: 6)
            )
    }
}
