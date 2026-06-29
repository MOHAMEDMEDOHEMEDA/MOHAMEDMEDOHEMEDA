//
//  SupportSuggestion.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import Foundation

struct SupportSuggestion: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let message: String
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case message
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
