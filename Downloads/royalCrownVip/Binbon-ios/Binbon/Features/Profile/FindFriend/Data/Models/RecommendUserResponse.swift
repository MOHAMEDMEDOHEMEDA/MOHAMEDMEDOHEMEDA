//
//  RecommendUserResponse.swift
//  Binbon
//
//  Created by Salah Khaled on 03/05/2026.
//


import Foundation

struct RecommendUserResponse: Codable, Identifiable {
    
    let id: Int?
    let fullname: String?
    let username: String?
    let profilePhoto: String?
    let userEmail: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullname
        case username
        case profilePhoto = "profile_photo"
        case userEmail = "user_email"
        case bio
    }
}
