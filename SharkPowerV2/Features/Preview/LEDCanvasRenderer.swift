//
//  LEDCanvasRenderer.swift
//  SharkPowerV2
//
//  Photorealistic continuous automotive light bar renderer using SwiftUI GraphicsContext.
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
        let barHeight: CGFloat = min(22, size.height * 0.35)
        let barY = (size.height - barHeight) / 2.0 - 4
        let cornerRadius: CGFloat = barHeight / 2.0

        let housingRect = CGRect(x: paddingH - 3, y: barY - 3, width: barWidth + 6, height: barHeight + 6)
        let tubeRect = CGRect(x: paddingH, y: barY, width: barWidth, height: barHeight)

        // 1. Draw Recessed Automotive Headlight/Taillight Housing
        let housingPath = Path(roundedRect: housingRect, cornerRadius: cornerRadius + 2)
        context.fill(
            housingPath,
            with: .color(SharkTheme.backgroundPrimary)
        )
        context.stroke(
            housingPath,
            with: .linearGradient(
                Gradient(colors: [SharkTheme.borderGlow.opacity(0.3), SharkTheme.borderSubtle]),
                startPoint: CGPoint(x: housingRect.midX, y: housingRect.minY),
                endPoint: CGPoint(x: housingRect.midX, y: housingRect.maxY)
            ),
            lineWidth: 1.5
        )

        // 2. Sample intensities along continuous strip
        let sampleCount = max(60, min(140, Int(barWidth / 2.5)))
        let sliceWidth = barWidth / CGFloat(sampleCount)
        var intensities: [CGFloat] = []
        intensities.reserveCapacity(sampleCount)

        for i in 0..<sampleCount {
            let normalizedPos = (CGFloat(i) + 0.5) / CGFloat(sampleCount)
            let rawIntensity = animation.intensity(at: normalizedPos, time: time, parameters: parameters)
            intensities.append(max(0.0, min(1.0, rawIntensity * CGFloat(parameters.brightness))))
        }

        // 3. Ambient Floor Reflection (Cockpit ground reflection beneath the bar)
        let reflectionY = barY + barHeight + 6
        let reflectionHeight: CGFloat = 14
        for i in 0..<sampleCount {
            let intensity = intensities[i]
            if intensity > 0.03 {
                let sliceX = paddingH + (CGFloat(i) * sliceWidth)
                let rect = CGRect(x: sliceX, y: reflectionY, width: sliceWidth + 0.5, height: reflectionHeight)
                let reflectionColor = parameters.color.opacity(Double(intensity) * 0.18)
                context.fill(Path(rect), with: .color(reflectionColor))
            }
        }

        // 4. Draw Diffuse Outer Bloom for active continuous segments
        var bloomContext = context
        bloomContext.addFilter(.blur(radius: 8))
        for i in 0..<sampleCount {
            let intensity = intensities[i]
            if intensity > 0.05 {
                let sliceX = paddingH + (CGFloat(i) * sliceWidth)
                let rect = CGRect(x: sliceX - 2, y: barY - 4, width: sliceWidth + 4, height: barHeight + 8)
                let bloomColor = parameters.color.opacity(Double(intensity) * 0.45)
                bloomContext.fill(Path(rect), with: .color(bloomColor))
            }
        }

        // 5. Draw Continuous Acrylic Optic Core (Main Beam)
        for i in 0..<sampleCount {
            let intensity = intensities[i]
            let sliceX = paddingH + (CGFloat(i) * sliceWidth)
            let rect = CGRect(x: sliceX, y: barY, width: sliceWidth + 0.5, height: barHeight)

            // Base off-state dark diffuse acrylic
            let baseColor = SharkTheme.backgroundTertiary.opacity(0.8)
            context.fill(Path(rect), with: .color(baseColor))

            // Illuminated continuous segment
            if intensity > 0.01 {
                let litColor = parameters.color.opacity(Double(intensity))
                context.fill(Path(rect), with: .color(litColor))
            }
        }

        // 6. Draw Hot-White Specular Filament Center (Authentic COB / Neon DRL Look)
        let filamentHeight: CGFloat = 3.5
        let filamentY = barY + (barHeight - filamentHeight) / 2.0
        for i in 0..<sampleCount {
            let intensity = intensities[i]
            if intensity > 0.15 {
                let sliceX = paddingH + (CGFloat(i) * sliceWidth)
                let rect = CGRect(x: sliceX, y: filamentY, width: sliceWidth + 0.5, height: filamentHeight)
                let centerGlow = Color.white.opacity(Double(intensity) * 0.82)
                context.fill(Path(rect), with: .color(centerGlow))
            }
        }

        // 7. Outer Acrylic Lens Sheen / Reflection Bezel
        let lensHighlightPath = Path(
            roundedRect: CGRect(x: paddingH, y: barY, width: barWidth, height: barHeight * 0.45),
            cornerRadius: cornerRadius
        )
        context.fill(
            lensHighlightPath,
            with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.0)]),
                startPoint: CGPoint(x: tubeRect.midX, y: tubeRect.minY),
                endPoint: CGPoint(x: tubeRect.midX, y: tubeRect.minY + (barHeight * 0.45))
            )
        )

        // Subtle outer border stroke around tube
        context.stroke(
            Path(roundedRect: tubeRect, cornerRadius: cornerRadius),
            with: .color(Color.black.opacity(0.5)),
            lineWidth: 1.0
        )
    }
}
