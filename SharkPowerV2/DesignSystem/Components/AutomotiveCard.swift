//
//  AutomotiveCard.swift
//  SharkPowerV2
//
//  Native iOS 26 Liquid Glass Design System Card Surface & Ambient Framework.
//

import SwiftUI

public struct AutomotiveCard<Content: View>: View {
    private let content: Content
    private let glowColor: Color?
    private let cornerRadius: CGFloat

    public init(
        glowColor: Color? = nil,
        cornerRadius: CGFloat = SharkSpacing.Radius.glassCard,
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
                ZStack {
                    // 1. Native iOS Ultra-Thin Glass Material
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // 2. Translucent Obsidian Cockpit Tint
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(SharkTheme.glassSurfaceBase)

                    // 3. 2.5D Optical Glass Top Convex Sheen
                    VStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(SharkTheme.glassGlossSheen)
                            .frame(height: 48)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            .overlay(
                // 4. Refractive Specular Bevel Border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        SharkTheme.glassSpecularBorder(glowColor: glowColor),
                        lineWidth: SharkSpacing.Glass.borderWidth
                    )
            )
            // 5. Dual-Layer Depth: Tight Ground Shadow + Ambient Caustic Bloom
            .shadow(color: Color.black.opacity(0.45), radius: SharkSpacing.Glass.groundShadowRadius, x: 0, y: 7)
            .shadow(
                color: (glowColor ?? SharkTheme.neonCyan).opacity(glowColor != nil ? 0.22 : 0.0),
                radius: SharkSpacing.Glass.causticGlowRadius,
                x: 0,
                y: 3
            )
    }
}

public typealias LiquidGlassCard<Content: View> = AutomotiveCard<Content>

// MARK: - Dynamic Living Liquid Ambient Background
public struct LiquidAmbientBackground: View {
    public let accentColor: Color?
    @State private var auraPulse: Bool = false

    public init(accentColor: Color? = nil) {
        self.accentColor = accentColor
    }

    public var body: some View {
        ZStack {
            // Base Obsidian Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.04, blue: 0.07),
                    Color(red: 0.06, green: 0.08, blue: 0.13),
                    Color(red: 0.02, green: 0.03, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Chromatic Liquid Aura 1 (Top-Trailing)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (accentColor ?? SharkTheme.neonCyan).opacity(0.20),
                            (accentColor ?? SharkTheme.neonCyan).opacity(0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .offset(x: auraPulse ? 130 : 160, y: auraPulse ? -180 : -140)
                .blur(radius: 50)

            // Chromatic Liquid Aura 2 (Mid-Bottom Leading)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SharkTheme.ultraViolet.opacity(0.15),
                            SharkTheme.electricBlue.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 260
                    )
                )
                .frame(width: 480, height: 480)
                .offset(x: auraPulse ? -140 : -100, y: auraPulse ? 240 : 280)
                .blur(radius: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
                auraPulse.toggle()
            }
        }
    }
}

// MARK: - Liquid Glass Surface View Modifier
public struct LiquidGlassSurfaceModifier: ViewModifier {
    public let cornerRadius: CGFloat
    public let glowColor: Color?

    public init(cornerRadius: CGFloat = SharkSpacing.Radius.glassCard, glowColor: Color? = nil) {
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
    }

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(SharkTheme.glassSurfaceBase)
                    VStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(SharkTheme.glassGlossSheen)
                            .frame(height: 38)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        SharkTheme.glassSpecularBorder(glowColor: glowColor),
                        lineWidth: SharkSpacing.Glass.borderWidth
                    )
            )
            .shadow(color: Color.black.opacity(0.40), radius: 10, x: 0, y: 5)
            .shadow(
                color: (glowColor ?? Color.clear).opacity(glowColor != nil ? 0.20 : 0.0),
                radius: 18,
                x: 0,
                y: 2
            )
    }
}

extension View {
    public func liquidGlassSurface(
        cornerRadius: CGFloat = SharkSpacing.Radius.glassCard,
        glowColor: Color? = nil
    ) -> some View {
        modifier(LiquidGlassSurfaceModifier(cornerRadius: cornerRadius, glowColor: glowColor))
    }
}
