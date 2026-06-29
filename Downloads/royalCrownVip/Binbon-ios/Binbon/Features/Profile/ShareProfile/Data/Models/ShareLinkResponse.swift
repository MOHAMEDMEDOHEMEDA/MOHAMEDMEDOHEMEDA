//
//  ShareLinkResponse.swift
//  Binbon
//
//  Created by Salah Khaled on 03/05/2026.
//

import Foundation

struct ShareLinkResponse: Codable {
    
    let username: String?
    let shareUrl: String?
    let deepLink: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case shareUrl = "share_url"
        case deepLink = "deep_link"
    }
}
