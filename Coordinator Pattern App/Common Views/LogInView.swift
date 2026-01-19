//
//  LogInView.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 15.01.2026.
//

import SwiftUI

struct LogInView<Container: AppContainerProtocol>: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @Bindable private var appContainer: Container
    
    init(appContainer: Container) {
        self.appContainer = appContainer
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("LogIn")
                .font(.headline)
            
            TextField("Enter your email", text: $email)
                .padding(.horizontal, 24)
                .frame(height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1))
                }
                .padding(.horizontal, 24)
            
            TextField("Enter your password", text: $password)
                .padding(.horizontal, 24)
                .frame(height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1))
                }
                .padding(.horizontal, 24)
            
            Button {
                Task {
                    await appContainer.logIn(with: email,
                                             and: password)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.red)
                    Text("LogIn")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .frame(height: 56)
            }
        }
    }
}

#Preview {
    LogInView(appContainer: AppContainer())
}
