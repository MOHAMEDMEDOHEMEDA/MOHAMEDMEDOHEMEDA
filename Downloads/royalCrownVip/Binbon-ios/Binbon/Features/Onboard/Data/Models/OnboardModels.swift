//
//  OnboardModels.swift
//  Binbon
//
//  Created by Salah Khaled on 18/05/2026.
//

import Foundation

// MARK: - Onboarding Suggestion Response
struct OnboardSuggestionResponse: Codable, Identifiable, Hashable {
    let id: Int?
    let fullname: String?
    let username: String?
    let profilePhoto: String?
    let userEmail: String?
    let bio: String?
    let gender: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullname
        case username
        case profilePhoto = "profile_photo"
        case userEmail = "user_email"
        case bio
        case gender = "geneder"
    }
}

// MARK: - Follow Selected Request
struct FollowSelectedRequest: Encodable {
    let userIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
    }
}
