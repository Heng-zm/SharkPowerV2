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

    public init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.70)

        let itemAppearance = UITabBarItemAppearance()
        let unselectedColor = UIColor(red: 0.50, green: 0.55, blue: 0.65, alpha: 1.0)
        let selectedColor = UIColor(red: 0.0, green: 0.88, blue: 1.0, alpha: 1.0)

        itemAppearance.normal.iconColor = unselectedColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

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
