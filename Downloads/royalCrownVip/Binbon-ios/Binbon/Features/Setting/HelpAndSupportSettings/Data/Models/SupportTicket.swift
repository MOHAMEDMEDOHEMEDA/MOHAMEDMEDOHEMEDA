//
//  SupportTicket.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import Foundation

struct SupportTicket: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let problemDescription: String?
    let attachment: String?
    let attachmentUrl: String?
    let status: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case problemDescription = "problem_description"
        case attachment
        case attachmentUrl = "attachment_url"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
