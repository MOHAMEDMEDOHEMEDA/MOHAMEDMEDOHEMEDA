//
//  FollowUserResponse.swift
//  Binbon
//
//  Created by Salah Khaled on 29/04/2026.
//

import Foundation

struct FollowUserResponse: Codable, Identifiable {
    
    let id: Int?
    let fullname: String?
    let username: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullname
        case username
        case profilePhoto = "profile_photo"
    }
}
