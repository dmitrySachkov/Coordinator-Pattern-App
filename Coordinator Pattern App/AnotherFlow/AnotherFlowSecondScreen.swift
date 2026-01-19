//
//  AnotherFlowSecondScreen.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct AnotherFlowSecondScreen: View {
    @Bindable var appContainer: AppContainer
    @Environment(Navigator<SecondNavigationRouter>.self) private var navigator
    
    var body: some View {
        VStack {
            Text("AnotherFlowSecondScreen")
            
            Button {
                appContainer.userState = .unauthorized
                appContainer.appState = .logIn
            } label: {
                Text("Log out")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                let router: FirstNavigationRouter = RouteBuilder.createRoute(appContainer, id: "thirdScreen")
                appContainer.firstRoute.setPath(router)
                appContainer.tabBarRouter.selection = 0
            } label: {
                Text("Simulate deep link")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    AnotherFlowSecondScreen(appContainer: AppContainer())
        .environment(Navigator<SecondNavigationRouter>())
}
