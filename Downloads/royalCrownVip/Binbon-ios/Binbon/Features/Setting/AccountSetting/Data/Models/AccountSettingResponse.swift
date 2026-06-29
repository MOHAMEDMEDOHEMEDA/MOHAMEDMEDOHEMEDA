//
//  AccountSettingResponse.swift
//  Binbon
//
//  Created by Salah Khaled on 10/05/2026.
//

import Foundation

// MARK: - Account Setting
struct AccountSettingResponse: Codable {
    let id: Int?
    let username: String?
    let email: String?
    let phone: String?
    let bio: String?
    let gender: String?
    let dateOfBirth: String?
    let zodiac: String?
    let location: LocationSettingModel?
    let avatar: AvatarSettingModel?
    var avatars: [UserAvatarModel]?
    let socialLinks: SocialSettingModel?
    let profilePhotoSliderEnabled: Bool?
    let connectedDevices: [DeviceSettingModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case phone
        case bio
        case gender
        case dateOfBirth = "date_of_birth"
        case zodiac
        case location
        case avatar
        case avatars
        case socialLinks = "social_links"
        case profilePhotoSliderEnabled = "profile_photo_slider_enabled"
        case connectedDevices = "connected_devices"
    }
}

// MARK: - Location
struct LocationSettingModel: Codable {
    let country: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Avatar
struct AvatarSettingModel: Codable {
    let avatarId: Int?
    let profilePhoto: String?
    let profilePhotoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case profilePhoto = "profile_photo"
        case profilePhotoUrl = "profile_photo_url"
    }
}

// MARK: - Social
struct SocialSettingModel: Codable {
    let hideSocialLinks: Bool?
    let items: [SocialMediaModel]?
    
    enum CodingKeys: String, CodingKey {
        case hideSocialLinks = "hide_social_links"
        case items
    }
}

struct SocialMediaModel: Codable {
    let id: Int?
    let platform: String?
    let url: String?
}


// MARK: - Device
struct DeviceSettingModel: Codable {
    let id: Int?
    let deviceName: String?
    let deviceType: String?
    let location: String?
    let isActive: Bool?
    let activityStatus: String?
    let lastLoginAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case deviceName = "device_name"
        case deviceType = "device_type"
        case location
        case isActive = "is_active"
        case activityStatus = "activity_status"
        case lastLoginAt = "last_login_at"
    }
}

// MARK: - Uploaded Avatar Response
struct UploadedAvatarResponse: Codable {
    let avatarUploaded: [UserAvatarModel]?
    
    enum CodingKeys: String, CodingKey {
        case avatarUploaded = "avatar_uploaded"
    }
}



// MARK: - Delete Avatar Response
struct DeleteAvatarResponse: Codable {
    let deletedAvatarId: Int?
    let remainingAvatars: Int?
    let primaryAvatarId: Int?
    let profilePhoto: String?
    let profilePhotoUrl: String?
    
    
    enum CodingKeys: String, CodingKey {
        case deletedAvatarId = "avatar_id"
        case remainingAvatars = "remaining_avatars"
        case primaryAvatarId = "primary_avatar_id"
        case profilePhoto = "profile_photo"
        case profilePhotoUrl = "profile_photo_url"
        
    }
}
