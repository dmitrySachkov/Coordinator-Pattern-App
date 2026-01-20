//
//  AppViewModel.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 12.01.2026.
//

import SwiftUI
import Observation

protocol AppViewModelProtocol {
    func getMainPageData() async
}

@Observable
final class AppViewModel: AppViewModelProtocol {
    
    func getMainPageData() async {
        do {
            let response = try await NetworkManager.shared.request(CatalogSectionsRouter(),
                                                                   type: CatalogSectionsModel.self)
            print("App data: ", response.data as Any)
        } catch {
            print("Error:", error)
        }
    }
}

struct CatalogSectionsRouter: Endpoint {
    var path = "/catalog/sections"
    var method: HTTPMethod = .GET
}

typealias CatalogSectionsModel = CatalogSectionBackendModel

struct CatalogSectionBackendModel: Codable {
    let data: [CatalogSectionsModelElement]
    let success: Bool
}

struct CatalogSectionsModelElement: Codable, Identifiable {
    let id: Int
    let code: String
    let name: String
    let parent: Int
    let picture: String
}
