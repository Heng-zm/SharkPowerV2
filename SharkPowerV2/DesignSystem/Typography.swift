//
//  Typography.swift
//  SharkPowerV2
//
//  Clean automotive typography with full Dynamic Type support.
//

import SwiftUI

public enum SharkTypography {
    public static let displayTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    public static let sectionTitle = Font.system(size: 20, weight: .semibold, design: .rounded)
    public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    public static let subheadline = Font.system(size: 15, weight: .medium, design: .default)
    public static let body = Font.system(size: 15, weight: .regular, design: .default)
    public static let caption = Font.system(size: 13, weight: .medium, design: .default)
    public static let telemetryMono = Font.system(size: 12, weight: .semibold, design: .monospaced)
    public static let badge = Font.system(size: 11, weight: .bold, design: .rounded)
}
