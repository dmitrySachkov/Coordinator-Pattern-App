//
//  NavigatorStack.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct NavigatorStack<CoordinatorPage: Coordinatable>: View {
    
    @Bindable private var coordinator: Navigator<CoordinatorPage>
    @Environment(AppContainer.self) private var appContainer
    
    let root: CoordinatorPage
    let tabIndex: Int?
    
    init(_ root: CoordinatorPage, coordinator: Navigator<CoordinatorPage>, tabIndex: Int? = nil) {
        self.root = root
        self.tabIndex = tabIndex
        self.coordinator = coordinator
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root
                .navigationDestination(for: CoordinatorPage.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0
                    .presentationDetents(coordinator.sheetParam)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { $0 }
                .environment(appContainer)
        }
        .environment(coordinator)
        .environment(appContainer)
//        .onAppear {
//            if let tabIndex = tabIndex {
//                appContainer.tabBarRouter.setCoordinator(coordinator, forTab: tabIndex)
//            }
//        }
    }
}
