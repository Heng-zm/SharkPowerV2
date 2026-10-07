//
//  LEDCanvasRenderer.swift
//  SharkPowerV2
//
//  Photorealistic continuous automotive light bar renderer using SwiftUI GraphicsContext.
//  Zero vertical slices, zero banding: rendered with continuous hardware-accelerated gradients.
//

import SwiftUI

public struct LEDCanvasRenderer {
    public static func render(
        context: inout GraphicsContext,
        size: CGSize,
        animation: LEDAnimation,
        time: TimeInterval,
        parameters: LEDAnimationParameters
    ) {
        guard size.width > 20 && size.height > 10 else { return }

        let paddingH: CGFloat = 16
        let barWidth = size.width - (paddingH * 2)
        let barHeight: CGFloat = max(18, min(42, size.height * 0.38))
        let barY = (size.height - barHeight) / 2.0
        let cornerRadius: CGFloat = barHeight / 2.0

        let housingRect = CGRect(x: paddingH - 4, y: barY - 4, width: barWidth + 8, height: barHeight + 8)
        let tubeRect = CGRect(x: paddingH, y: barY, width: barWidth, height: barHeight)
        let tubePath = Path(roundedRect: tubeRect, cornerRadius: cornerRadius)

        // 1. Recessed Automotive Channel (Carbon/Dark Metallic Housing)
        let housingPath = Path(roundedRect: housingRect, cornerRadius: cornerRadius + 3)
        context.fill(housingPath, with: .color(SharkTheme.backgroundPrimary))
        context.stroke(
            housingPath,
            with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)]),
                startPoint: CGPoint(x: housingRect.midX, y: housingRect.minY),
                endPoint: CGPoint(x: housingRect.midX, y: housingRect.maxY)
            ),
            lineWidth: 1.5
        )

        // 2. Build Continuous Gradient Stops from Animation Math
        // Sample at 48 points across strip for ultra-smooth GPU color transitions
        let sampleCount = 48
        var beamStops: [Gradient.Stop] = []
        var coreStops: [Gradient.Stop] = []
        var bloomStops: [Gradient.Stop] = []
        beamStops.reserveCapacity(sampleCount + 1)
        coreStops.reserveCapacity(sampleCount + 1)
        bloomStops.reserveCapacity(sampleCount + 1)

        for i in 0...sampleCount {
            let pos = CGFloat(i) / CGFloat(sampleCount)
            let rawIntensity = animation.intensity(at: pos, time: time, parameters: parameters)
            let intensity = max(0.0, min(1.0, rawIntensity * CGFloat(parameters.brightness)))

            // Main continuous beam color
            let beamColor = parameters.color.opacity(Double(intensity))
            beamStops.append(Gradient.Stop(color: beamColor, location: pos))

            // Diffuse outer bloom color
            let bloomColor = parameters.color.opacity(Double(intensity) * 0.6)
            bloomStops.append(Gradient.Stop(color: bloomColor, location: pos))

            // Hot-white laser core (activated where intensity is high)
            let coreAlpha = max(0.0, (Double(intensity) - 0.25) / 0.75) * 0.95
            let coreColor = Color.white.opacity(coreAlpha)
            coreStops.append(Gradient.Stop(color: coreColor, location: pos))
        }

        let startPoint = CGPoint(x: tubeRect.minX, y: tubeRect.midY)
        let endPoint = CGPoint(x: tubeRect.maxX, y: tubeRect.midY)

        // 3. Diffuse Outer Glow / Bloom (Seamless organic neon halo)
        var bloomContext = context
        bloomContext.addFilter(.blur(radius: 12))
        let bloomPath = Path(roundedRect: housingRect.insetBy(dx: -4, dy: -4), cornerRadius: cornerRadius + 6)
        bloomContext.fill(
            bloomPath,
            with: .linearGradient(
                Gradient(stops: bloomStops),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )

        // 4. Base Unlit Frosted Optic Tube (Deep smoky acrylic)
        context.fill(tubePath, with: .color(SharkTheme.backgroundTertiary.opacity(0.85)))

        // 5. Continuous Illuminated Beam Pass (Single gradient fill — zero slice artifacts)
        context.fill(
            tubePath,
            with: .linearGradient(
                Gradient(stops: beamStops),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )

        // 6. Hot Specular Core Filament (Center laser strip, Porsche / Audi DRL aesthetic)
        let coreHeight = max(3.0, barHeight * 0.28)
        let coreRect = CGRect(
            x: paddingH + (cornerRadius * 0.4),
            y: barY + (barHeight - coreHeight) / 2.0,
            width: barWidth - (cornerRadius * 0.8),
            height: coreHeight
        )
        let corePath = Path(roundedRect: coreRect, cornerRadius: coreHeight / 2.0)
        context.fill(
            corePath,
            with: .linearGradient(
                Gradient(stops: coreStops),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )

        // 7. Glass / Acrylic Tube Cylindrical Highlight (Top reflection sheen)
        let lensHighlightHeight = barHeight * 0.42
        let lensRect = CGRect(x: paddingH + 2, y: barY + 1, width: barWidth - 4, height: lensHighlightHeight)
        let lensPath = Path(roundedRect: lensRect, cornerRadius: cornerRadius - 1)
        context.fill(
            lensPath,
            with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.22), Color.white.opacity(0.0)]),
                startPoint: CGPoint(x: tubeRect.midX, y: lensRect.minY),
                endPoint: CGPoint(x: tubeRect.midX, y: lensRect.maxY)
            )
        )

        // 8. Crisp Outer Optical Bezel Stroke
        context.stroke(
            tubePath,
            with: .color(Color.black.opacity(0.4)),
            lineWidth: 1.0
        )
    }
}
