//
//  SecondMainScreen.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct SecondMainScreen: View {
    @Bindable var appContainer: AppContainer
    @Environment(Navigator<FirstNavigationRouter>.self) private var navigator
    
    var body: some View {
        VStack {
            Text("SecondMainScreen")
            
            Button {
                navigator.push(.thirdScreen(appContainer))
            } label: {
                Text("Go to next screen")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
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
    }
}

#Preview {
    SecondMainScreen(appContainer: AppContainer())
        .environment(Navigator<FirstNavigationRouter>())
}
