//
//  ContentView.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 12.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
   
    @Bindable var appContainer: AppContainer
    
    var body: some View {
        Group {
            switch appContainer.appState {
            case .firstEnter:
                EmptyView()
            case .logIn:
                LogInView(appContainer: appContainer)
            case .mainTab:
                TabBarView()
                    .environment(appContainer)
            }
        }
        .task {
            await appContainer.start()
        }
    }
}

#Preview {
    ContentView(appContainer: AppContainer())
}
