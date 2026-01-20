//
//  MainScreen.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct MainScreen: View {
    @State var viewModel: AppViewModelProtocol
    @Bindable var appContainer: AppContainer
    @Environment(Navigator<FirstNavigationRouter>.self) private var navigator
    let someName: String = "Dmitry"
    
    var body: some View {
        VStack {
            Text("Hi \(someName)!")
            
            Button {
                navigator.push(.secondScreen(appContainer))
            } label: {
                Text("Go to next screen")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                let router: SecondNavigationRouter = RouteBuilder.createRoute(appContainer, id: "secondScreen")
                appContainer.secondRoute.setPath(router)
                appContainer.tabBarRouter.selection = 1
            } label: {
                Text("Simulate deep link")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            await viewModel.getMainPageData()
        }
    }
}

#Preview {
    NavigationStack {
        MainScreen(viewModel: AppViewModel(), appContainer: AppContainer())
            .environment(Navigator<FirstNavigationRouter>())
    }
}
