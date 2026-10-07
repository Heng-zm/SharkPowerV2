//
//  AppRouter.swift
//  SharkPowerV2
//
//  Main application tab navigation structure.
//

import SwiftUI

public enum AppTab: Hashable {
    case home
    case devices
    case presets
    case settings
}

public struct AppRouter: View {
    @State private var selectedTab: AppTab = .home

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Cockpit", systemImage: "car.side.fill")
                }
                .tag(AppTab.home)

            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "antenna.radiowaves.left.and.right")
                }
                .tag(AppTab.devices)

            PresetsView()
                .tabItem {
                    Label("Presets", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(AppTab.presets)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(SharkTheme.neonCyan)
        .preferredColorScheme(.dark)
    }
}
