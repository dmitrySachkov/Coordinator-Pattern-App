//
//  AnotherFlowScreen.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct AnotherFlowScreen: View {
    
    @Bindable var appContainer: AppContainer
    @Environment(Navigator<SecondNavigationRouter>.self) private var navigator
    
    var body: some View {
        VStack {
            Text("AnotherFlowScreen")
            
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
    AnotherFlowScreen(appContainer: AppContainer())
        .environment(Navigator<SecondNavigationRouter>())
}
