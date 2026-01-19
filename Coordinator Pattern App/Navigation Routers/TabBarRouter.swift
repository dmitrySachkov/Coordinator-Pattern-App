//
//  TabBarRouter.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

@Observable
final class TabBarRouter {
    
    var selection = 0
    var pathToView = 0
    
    var coordinators: [Int: Any] = [:]
    
    func setCoordinator<T>(_ coordinator: Navigator<T>, forTab tab: Int) {
        coordinators[tab] = coordinator
    }
    
    func getCoordinator<T>(forTab tab: Int) -> Navigator<T>? {
        return coordinators[tab] as? Navigator<T>
    }
}
