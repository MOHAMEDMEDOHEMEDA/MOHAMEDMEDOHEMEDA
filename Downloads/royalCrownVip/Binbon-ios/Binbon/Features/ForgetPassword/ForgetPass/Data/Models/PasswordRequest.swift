//
//  PasswordRequest.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import Foundation

struct PasswordRequest: Codable, Hashable {
    
    var email: String?
    var code: String?
    var password: String?
    var passwordConfirm: String?
    
    enum CodingKeys: String, CodingKey {
        case email = "user_email"
        case code
        case password
        case passwordConfirm = "password_confirmation"
    }
}
