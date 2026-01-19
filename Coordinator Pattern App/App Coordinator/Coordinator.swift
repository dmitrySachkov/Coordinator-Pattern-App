//
//  Coordinator.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

protocol RouteFactory: Coordinatable {
    static func make(id: String, container: AppContainer) -> Self
}

struct RouteBuilder {
    static func createRoute<T: RouteFactory>(_ container: AppContainer, id: String) -> T {
        T.make(id: id, container: container)
    }
}

@Observable
final class AppCoordinator {
    
    var firstRoute = Navigator<FirstNavigationRouter>()
    var secondRoute = Navigator<SecondNavigationRouter>()
    var appContainer: AppContainer
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }
    
}
