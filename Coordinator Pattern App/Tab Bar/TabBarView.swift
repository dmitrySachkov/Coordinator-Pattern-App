//
//  TabBarView.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct TabBarView: View {
    @Environment(AppContainer.self) private var appContainer

    var body: some View {
        @Bindable var tabBarRouter = appContainer.tabBarRouter
        TabView(selection: $tabBarRouter.selection) {
            NavigatorStack(FirstNavigationRouter.mainScreen(appContainer),
                           coordinator: appContainer.firstRoute,
                           tabIndex: 0)
            .tabBarItem(.mainScreen, selection: appContainer.tabBarRouter.selection)

            NavigatorStack(SecondNavigationRouter.mainScreen(appContainer),
                           coordinator: appContainer.secondRoute,
                           tabIndex: 1)
            .tabBarItem(.anotherScreen, selection: appContainer.tabBarRouter.selection)
        }
        .environment(appContainer)
    }
}

extension View {
    func tabBarItem(_ item: TabBarItems, selection: Int) -> some View {
        self
            .tabItem {
                Label(item.title,
                      systemImage: item.systemImageName(isSelected: selection == item.tag))
            }
            .tag(item.tag)
    }
}

enum TabBarItems {
    case mainScreen
    case anotherScreen

    var tag: Int {
        switch self {
        case .mainScreen: return 0
        case .anotherScreen: return 1
        }
    }

    var title: String {
        switch self {
        case .mainScreen: return "main"
        case .anotherScreen: return "another"
        }
    }

    func systemImageName(isSelected: Bool) -> String {
        switch self {
        case .mainScreen: return isSelected ? "house.fill" : "house"
        case .anotherScreen: return isSelected ? "star.fill" : "star"
        }
    }
}
