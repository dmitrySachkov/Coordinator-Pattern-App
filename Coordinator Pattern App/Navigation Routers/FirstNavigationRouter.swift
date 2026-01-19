//
//  FirstNavigationRouter.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

enum FirstNavigationRouter: Coordinatable, RouteFactory {
    var id: String {
        switch self {
        case .mainScreen:
            "mainScreen"
        case .secondScreen:
            "secondScreen"
        case .thirdScreen:
            "thirdScreen"
        }
    }
    
    case mainScreen(AppContainer)
    case secondScreen(AppContainer)
    case thirdScreen(AppContainer)
    
    static func make(id: String, container: AppContainer) -> Self {
        switch id {
        case "mainScreen":   return .mainScreen(container)
        case "secondScreen": return .secondScreen(container)
        case "thirdScreen":  return .thirdScreen(container)
        default: fatalError("Unknown route \(id)")
        }
    }
    
    var body: some View {
        switch self {
        case .mainScreen(let container):
            MainScreen(appContainer: container)
        case .secondScreen(let container):
            SecondMainScreen(appContainer: container)
        case .thirdScreen(let container):
            ThirdMainScreen(appContainer: container)
        }
    }
    
    static func == (lhs: FirstNavigationRouter, rhs: FirstNavigationRouter) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
