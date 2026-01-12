//
//  Coordinator_Pattern_AppApp.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 12.01.2026.
//

import SwiftUI
import SwiftData

@main
struct Coordinator_Pattern_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
