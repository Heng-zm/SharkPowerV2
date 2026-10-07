//
//  Colors.swift
//  SharkPowerV2
//
//  Automotive dark-mode-first color palette tailored for continuous LED illumination.
//

import SwiftUI

public enum SharkTheme {
    // MARK: - Backgrounds (Cockpit / Automotive Aesthetic)
    public static let backgroundPrimary = Color(red: 0.04, green: 0.05, blue: 0.07)       // #0A0D12 deep carbon black
    public static let backgroundSecondary = Color(red: 0.08, green: 0.10, blue: 0.14)     // #141A24 brushed titanium / dark panel
    public static let backgroundTertiary = Color(red: 0.12, green: 0.15, blue: 0.20)      // #1F2633 subtle card surface
    public static let acrylicOverlay = Color(red: 0.16, green: 0.20, blue: 0.27).opacity(0.6)

    // MARK: - Accents & LED Illumination Defaults
    public static let neonCyan = Color(red: 0.0, green: 0.85, blue: 1.0)                 // #00D9FF laser cyan
    public static let electricBlue = Color(red: 0.12, green: 0.45, blue: 1.0)             // #1F73FF racing blue
    public static let daytonaRed = Color(red: 1.0, green: 0.18, blue: 0.22)               // #FF2E38 taillight red
    public static let cyberAmber = Color(red: 1.0, green: 0.65, blue: 0.0)                // #FFA600 sequential turn signal amber
    public static let acidGreen = Color(red: 0.15, green: 1.0, blue: 0.45)                // #26FF73 telemetry green
    public static let ultraViolet = Color(red: 0.65, green: 0.25, blue: 1.0)              // #A640FF night glow purple
    public static let pureWhite = Color(red: 0.98, green: 0.99, blue: 1.0)                // #FAFCFF xenon white

    // MARK: - Borders & Dividers
    public static let borderSubtle = Color.white.opacity(0.08)
    public static let borderGlow = Color.white.opacity(0.18)

    // MARK: - Text
    public static let textPrimary = Color.white
    public static let textSecondary = Color(red: 0.65, green: 0.70, blue: 0.78)
    public static let textMuted = Color(red: 0.42, green: 0.46, blue: 0.54)

    // MARK: - Status
    public static let statusConnected = Color(red: 0.15, green: 0.95, blue: 0.45)
    public static let statusScanning = Color(red: 0.0, green: 0.75, blue: 1.0)
    public static let statusDisconnected = Color(red: 0.55, green: 0.58, blue: 0.65)
    public static let statusWarning = Color(red: 1.0, green: 0.70, blue: 0.10)
    public static let statusError = Color(red: 1.0, green: 0.25, blue: 0.25)
}

// MARK: - Color Hex Extensions
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 217, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    public func toHex() -> String {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return "#00D9FF"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
