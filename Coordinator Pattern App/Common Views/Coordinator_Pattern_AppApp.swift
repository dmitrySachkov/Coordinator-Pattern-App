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
    
    @State private var appContainer: AppContainer
    
    init() {
        appContainer = AppContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(appContainer: appContainer)
        }
    }
}
