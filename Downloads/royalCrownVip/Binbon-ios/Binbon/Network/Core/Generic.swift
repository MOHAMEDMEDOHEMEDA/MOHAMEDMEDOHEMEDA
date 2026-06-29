//
//  Generic.swift
//  Binbon
//
//  Created by Salah Khaled on 02/03/2026.
//

import SwiftUI

// MARK: - Empty Response
struct EmptyResponse: Decodable { }


// MARK: - Base Response
struct BaseResponse<T: Decodable>: Decodable {
    let status: Bool?
    let message: String?
    let data: T?
}


// MARK: - Fail Response
struct FailResponse: Decodable {
    let status: Bool?
    let message: String?
}


// MARK: - API Error
struct APIError: Error {
    var type: APIErrorType
    var code: Int = 0
    var message: String?
    
    func localizedMessage() -> String {
//        message ?? ("error" + type.rawValue.capitalized).localize
        message ?? ("Error: " + type.rawValue.capitalized)
    }
}

enum APIErrorType: String {
    case url
    case request
    case network
    case parsing
    case unauthorized
    case server
    case backend
    case unknown
}
