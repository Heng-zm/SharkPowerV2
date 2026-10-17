//
//  ActionButton.swift
//  SharkPowerV2
//
//  Native iOS 26 Liquid Glass high-impact action control with tactile micro-spring physics.
//

import SwiftUI

public enum ActionButtonStyle {
    case primary(Color)
    case secondary
    case danger
}

public struct ActionButton: View {
    public let title: String
    public let systemImage: String?
    public let style: ActionButtonStyle
    public let isLoading: Bool
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        style: ActionButtonStyle = .primary(SharkTheme.neonCyan),
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            Haptics.shared.mediumImpact()
            action()
        }) {
            HStack(spacing: SharkSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.9)
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(SharkTypography.headline)
                }

                Text(title)
                    .font(SharkTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(foregroundColor)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous))
            .overlay(
                // Top Specular Glass Sheen
                VStack {
                    RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0.06), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 24)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous)
                    .stroke(borderStrokeGradient, lineWidth: SharkSpacing.Glass.borderWidth)
            )
            .shadow(color: shadowColor, radius: 12, x: 0, y: 5)
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(LiquidScaleButtonStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return SharkTheme.backgroundPrimary
        case .secondary:
            return Color.white
        case .danger:
            return Color.white
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary(let tint):
            LinearGradient(
                colors: [tint, tint.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .secondary:
            ZStack {
                RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: SharkSpacing.Radius.glassButton, style: .continuous)
                    .fill(SharkTheme.glassSurfaceElevated)
            }
        case .danger:
            LinearGradient(
                colors: [SharkTheme.daytonaRed, SharkTheme.daytonaRed.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var borderStrokeGradient: LinearGradient {
        switch style {
        case .primary(let tint):
            return LinearGradient(
                colors: [Color.white.opacity(0.55), tint.opacity(0.4), Color.white.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return SharkTheme.glassSpecularBorder()
        case .danger:
            return LinearGradient(
                colors: [Color.white.opacity(0.5), SharkTheme.daytonaRed.opacity(0.5), Color.white.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary(let tint):
            return tint.opacity(0.38)
        case .secondary:
            return Color.black.opacity(0.35)
        case .danger:
            return SharkTheme.daytonaRed.opacity(0.45)
        }
    }
}

private struct LiquidScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? 0.05 : 0.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
