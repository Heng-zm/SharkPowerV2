//
//  SharkPowerApp.swift
//  SharkPowerV2
//
//  Native iOS Application entrypoint for Shark Power V2 Sequential Lighting Controller.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct SharkPowerApp: App {
    let container: ModelContainer

    init() {
        self.container = SharkModelContainer.create()
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .modelContainer(container)
        }
    }
}
