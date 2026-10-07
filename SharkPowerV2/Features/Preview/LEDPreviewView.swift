//
//  LEDPreviewView.swift
//  SharkPowerV2
//
//  Live continuous LED light strip preview powered by TimelineView and Canvas.
//  Strictly continuous light-bar representation without dot or segment artifacts.
//

import SwiftUI

public struct LEDPreviewView: View {
    public let mode: LEDMode
    public let parameters: LEDAnimationParameters
    public var isInteractive: Bool = true
    public var onExpandTapped: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    // Cached animation strategy instances
    private let staticAnim = StaticAnimation()
    private let forwardAnim = ForwardAnimation()
    private let reverseAnim = ReverseAnimation()
    private let trailingAnim = TrailingAnimation()
    private let chasingAnim = ChasingAnimation()

    public init(
        mode: LEDMode,
        parameters: LEDAnimationParameters,
        isInteractive: Bool = true,
        onExpandTapped: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.parameters = parameters
        self.isInteractive = isInteractive
        self.onExpandTapped = onExpandTapped
    }

    public var body: some View {
        VStack(spacing: SharkSpacing.xxs) {
            // Header telemetry & expand button
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: mode.iconName)
                        .font(SharkTypography.caption)
                        .foregroundStyle(parameters.color)

                    Text(mode.rawValue.uppercased())
                        .font(SharkTypography.telemetryMono)
                        .foregroundStyle(SharkTheme.textPrimary)

                    Text("• LIVE SEQUENTIAL")
                        .font(SharkTypography.badge)
                        .foregroundStyle(SharkTheme.neonCyan)
                }

                Spacer()

                if let onExpandTapped = onExpandTapped {
                    Button(action: {
                        Haptics.shared.lightImpact()
                        onExpandTapped()
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SharkTheme.textSecondary)
                            .padding(6)
                            .background(Circle().fill(SharkTheme.backgroundTertiary))
                    }
                    .accessibilityLabel("Open full screen preview")
                }
            }
            .padding(.horizontal, SharkSpacing.md)
            .padding(.top, SharkSpacing.sm)

            // TimelineView Canvas Renderer (Continuous Smooth Neon Bar)
            TimelineView(.animation(paused: scenePhase != .active)) { timeline in
                let continuousTime = reduceMotion ? 0.0 : timeline.date.timeIntervalSinceReferenceDate
                let activeAnim = activeAnimation(for: mode)

                Canvas { context, size in
                    LEDCanvasRenderer.render(
                        context: &context,
                        size: size,
                        animation: activeAnim,
                        time: continuousTime,
                        parameters: parameters
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .padding(.bottom, SharkSpacing.xs)
        }
        .background(
            RoundedRectangle(cornerRadius: SharkSpacing.Radius.large, style: .continuous)
                .fill(SharkTheme.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: SharkSpacing.Radius.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [parameters.color.opacity(0.3), SharkTheme.borderSubtle],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: parameters.color.opacity(0.12), radius: 16, x: 0, y: 6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sequential LED preview: Mode \(mode.rawValue), Brightness \(Int(parameters.brightness * 100)) percent, Speed \(Int(parameters.speed * 100)) percent")
    }

    private func activeAnimation(for mode: LEDMode) -> LEDAnimation {
        switch mode {
        case .staticGlow: return staticAnim
        case .forward: return forwardAnim
        case .reverse: return reverseAnim
        case .trailing: return trailingAnim
        case .chasing: return chasingAnim
        }
    }
}
