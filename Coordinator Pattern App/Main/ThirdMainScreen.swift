//
//  ThirdMainScreen.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

struct ThirdMainScreen: View {
    @Bindable var appContainer: AppContainer
    @Environment(Navigator<FirstNavigationRouter>.self) private var navigator
    
    var body: some View {
        Text("ThirdMainScreen")
    }
}

#Preview {
    ThirdMainScreen(appContainer: AppContainer())
        .environment(Navigator<FirstNavigationRouter>())
}
