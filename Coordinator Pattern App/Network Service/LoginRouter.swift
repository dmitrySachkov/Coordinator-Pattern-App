//
//  LoginRouter.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 19.01.2026.
//

import SwiftUI

//struct AppToken {
//    static var bearerToken = ""
//}


struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
}

struct AuthenticationLoginResponse: Decodable {
    let country: String
    let language: String
    let isGlobalDelivery: Bool?
    let member: MemberModel?
    
    struct MemberModel: Decodable {
        let id: Int
        let surname: String
        let name: String
        let avatar: String?
        let patronymic: String?
        let position: String
    }
}

struct AuthenticationSessionResponse: Decodable {
    let success: Bool
    let data: AuthenticationTokenBackendResponse
}

struct AuthenticationTokenBackendResponse: Decodable {
    let tokenType: String
    let expiresIn: Int
    let accessToken: String
    
//    enum CodingKeys: String, CodingKey {
//        case tokenType = "token_type"
//        case expires = "expires_in"
//        case accessToken = "access_token"
//    }
}

struct SessionParams: Encodable {
    var applicationToken: String
    var language: String
    let deliveryId: String
    var device: DeviceSessionParams
    
    struct DeviceSessionParams: Encodable {
        var uuid: String
        var notificationToken: String?
    }
    
    init(applicationToken: String, deliveryId: String, language: String, notificationToken: String? = nil) {
        self.applicationToken = applicationToken
        self.language = language
        self.deliveryId = deliveryId
        self.device = DeviceSessionParams(uuid: UUID().uuidString, notificationToken: notificationToken)
    }
}

struct AuthenticationBackendResponse: Decodable {
    let success: Bool
    let data: [AuthenticationLoginResponse]
}

struct LoginParams: Codable {
    var login: String
    var password: String
}

struct AuthenticationCheckSessionResponse: Decodable {
    let success: Bool
    let data: AuthenticationLoginResponse
}

extension Encodable {
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
    
    var asArray: [Any] {
        guard let data = try? JSONEncoder().encode(self),
              let array = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
            return []
        }
        return array
    }
}

struct AuthenticationCheckSessionRouter: Endpoint {
    var path: String = "/auth/session"
    var method: HTTPMethod = .GET
    var requiresAuthentication: Bool { true }
}

struct AuthenticationPostSessionRouter: Endpoint {
    let params: SessionParams
    var path: String = "/auth/session"
    var method: HTTPMethod = .POST
    var body: HTTPBody? { .jsonEncodable(params) }
    var requiresAuthentication: Bool { false }
    
    init(params: SessionParams) {
        self.params = params
    }
}

struct AuthenticationDeleteSessionRouter: Endpoint {
    var path: String = "/auth/session"
    var method: HTTPMethod = .DELETE
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Accept": "*/*",
            "Content-Type": "application/json"
        ]
        
        if !AppToken.bearerToken.isEmpty {
            headers["Authorization"] = AppToken.bearerToken
        }
        
        return headers
    }
}

struct AuthenticationPostLoginRouter: Endpoint {
    let params: LoginParams
    var path: String = "/auth/login"
    var method: HTTPMethod = .POST
    var body: HTTPBody? { .jsonEncodable(params) }
    
    init(params: LoginParams) {
        self.params = params
    }
}

struct AuthenticationLogoutLoginRouter: Endpoint {
    typealias ReturnType = AuthenticationCheckSessionResponse
    var path: String = "/auth/logout"
    var method: HTTPMethod = .POST
}
