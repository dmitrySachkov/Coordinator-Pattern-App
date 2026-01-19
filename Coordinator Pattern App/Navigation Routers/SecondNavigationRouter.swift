//
//  SecondNavigationRouter.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

enum SecondNavigationRouter: Coordinatable, RouteFactory {
    var id: String {
        switch self {
        case .mainScreen:
            "mainScreen"
        case .secondScreen:
            "secondScreen"
        }
    }
    
    case mainScreen(AppContainer)
    case secondScreen(AppContainer)
    
    static func make(id: String, container: AppContainer) -> Self {
        switch id {
        case "mainScreen":   return .mainScreen(container)
        case "secondScreen": return .secondScreen(container)
        default: fatalError("Unknown route \(id)")
        }
    }
    
    var body: some View {
        switch self {
        case .mainScreen(let container):
            AnotherFlowScreen(appContainer: container)
        case .secondScreen(let container):
            AnotherFlowSecondScreen(appContainer: container)
        }
    }
    
    static func == (lhs: SecondNavigationRouter, rhs: SecondNavigationRouter) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
