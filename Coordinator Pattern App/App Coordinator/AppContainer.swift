//
//  AppContainer.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI


enum UserState {
    case authorized
    case unauthorized
}

enum AppState {
    case firstEnter
    case logIn
    case mainTab
}

protocol AppContainerProtocol: AnyObject, Observable {
    var userState: UserState { get set }
    var appState: AppState { get set }
    var tabBarRouter: TabBarRouter { get set }
    var firstRoute: Navigator<FirstNavigationRouter>  { get set }
    var secondRoute: Navigator<SecondNavigationRouter>  { get set }
    func start() async
    func logIn(with id: String, and password: String) async
}

@Observable
class AppContainer: AppContainerProtocol {
    
    var userState: UserState = .unauthorized
    var appState: AppState = .logIn
    var tabBarRouter: TabBarRouter = TabBarRouter()
    var firstRoute = Navigator<FirstNavigationRouter>()
    var secondRoute = Navigator<SecondNavigationRouter>()
    
    func start() async {
        var isSessionExists: Bool = false
        do {
            isSessionExists = try await checkSession()
        } catch {
            print("Error:", error)
        }
        
        if !isSessionExists {
            await openSession()
        }
    }
    
    func logIn(with id: String, and password: String) async {
        let params = LoginParams(login: id, password: password)
        let router = AuthenticationPostLoginRouter(bodyParameters: params)
        
        do {
            let response = try await NetworkManager.shared.requestWithRetry(router,
                                                                            type: APIResponse<AuthenticationLoginResponse>.self)
            if response.data?.member?.id != nil {
                appState = .mainTab
                userState = .authorized
            }
        } catch {
            print("Error:", error)
        }
    }
    
    private func openSession() async {
        let sessionParams = SessionParams(applicationToken: "1ed753ba-a751-6616-a186-2f45ac2765d9", deliveryId: "RU", language: "ru", notificationToken: "notificationToken")
        
        do {
            let response = try await NetworkManager.shared.requestWithRetry(AuthenticationPostSessionRouter(body: sessionParams), type: AuthenticationSessionResponse.self)
            
            AppToken.bearerToken = response.data.type + " " + response.data.accessToken
        } catch {
            print("Error openSession:", error)
        }
    }
    
    private func checkSession() async throws -> Bool {
        let checkSessionRouter = AuthenticationCheckSessionRouter()
        do {
            _ = try await NetworkManager.shared.requestWithRetry(checkSessionRouter, type: APIResponse<AuthenticationLoginResponse>.self)
            return true
        } catch {
            print("Error:", error)
            return false
        }
    }
}
