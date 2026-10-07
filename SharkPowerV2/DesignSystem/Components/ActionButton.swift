//
//  ActionButton.swift
//  SharkPowerV2
//
//  High-impact automotive action button with haptic feedback & state animations.
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
            .frame(height: 50)
            .foregroundStyle(foregroundColor)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: SharkSpacing.Radius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SharkSpacing.Radius.medium, style: .continuous)
                    .stroke(borderStrokeColor, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(ScaleButtonStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return SharkTheme.backgroundPrimary
        case .secondary:
            return SharkTheme.textPrimary
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
            SharkTheme.backgroundTertiary
        case .danger:
            LinearGradient(
                colors: [SharkTheme.daytonaRed, SharkTheme.daytonaRed.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var borderStrokeColor: Color {
        switch style {
        case .primary:
            return Color.white.opacity(0.2)
        case .secondary:
            return SharkTheme.borderGlow
        case .danger:
            return Color.white.opacity(0.2)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary(let tint):
            return tint.opacity(0.3)
        case .secondary:
            return Color.black.opacity(0.3)
        case .danger:
            return SharkTheme.daytonaRed.opacity(0.4)
        }
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
