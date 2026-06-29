//
//  AccountSettingRequest.swift
//  Binbon
//
//  Created by Salah Khaled on 10/05/2026.
//

import Foundation

struct AccountLinkRequest: Codable {
    var id: Int?
    var title: String?
    var url: String?
}

struct SaveAccountRequest: Codable {

    var username: String
    var bio: String
    var phone: String
    var email: String
    var dateOfBirth: String
    var gender: String
    var profilePhotoSliderEnabled: Bool
    var hideSocialLinks: Bool
    var avatarId: Int?
    
    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case phone
        case email
        case dateOfBirth = "date_of_birth"
        case gender
        case profilePhotoSliderEnabled = "profile_photo_slider_enabled"
        case hideSocialLinks = "hide_social_links"
        case avatarId = "avatar_id"
    }
}
