//
//  EditProfileRequest.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import Foundation

struct EditProfileRequest: Codable {
    let fullname: String
    let username: String?
    let bio: String
    let gender: String
    let dateOfBirth: String
    
    enum CodingKeys: String, CodingKey {
        case fullname
        case username
        case bio
        case gender
        case dateOfBirth = "date_of_birth"
    }
}
