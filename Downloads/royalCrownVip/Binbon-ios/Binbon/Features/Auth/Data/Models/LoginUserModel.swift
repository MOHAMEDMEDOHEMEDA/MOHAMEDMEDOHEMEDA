//
//  LoginUserModel.swift
//  Binbon
//
//  Created by Salah Khaled on 20/04/2026.
//

import Foundation

// MARK: - Login User Request
struct LoginUserRequest: Codable {
    
    var email: String?
    var password: String?
    var deviceType: String?
    var operatingSystem: String?
    
    enum CodingKeys: String, CodingKey {
        case email = "user_email"
        case password
        case deviceType = "device_type"
        case operatingSystem = "operating_system"
    }
}

// MARK: - Login User Response
struct UserResponse: Codable {
    let id: Int?
    let isDummy: Int?
    let identity: String?
    let fullname: String?
    let username: String?
    let usernameUpdatedAt: String?
    let userEmail: String?
    let emailVerifiedAt: String?
    let gender: String?
    let dateOfBirth: String?
    let zodiac: String?
    #warning("Int or String")
//    let mobileCountryCode: Int?
    let userMobileNo: String?
    let phoneVerifiedAt: String?
    var profilePhoto: String?
    let loginMethod: String?
    let authMode: String?
    let device: Int?
    let deviceToken: String?
    let notifyPostLike: Int?
    let notifyPostComment: Int?
    let notifyFollow: Int?
    let notifyMention: Int?
    let notifyGiftReceived: Int?
    let notifyChat: Int?
    let isVerify: Int?
    let whoCanViewPost: Int?
    let showMyFollowing: Int?
    let receiveMessage: Int?
    let receiveGiftsEnabled: Int?
    let coinWallet: Int?
    let bio: String?
    let followerCount: Int?
    let followingCount: Int?
    let friendsCount: Int?
    let totalPostLikesCount: Int?
    let isFreez: Int?
    let startFreezeAt: String?
    let endFreezeAt: String?
    let country: String?
    let countryCode: String?
    let region: String?
    let regionName: String?
    let city: String?
    let postalCode: String?
    let lat: Double?
    let lon: Double?
    let timezone: String?
    let appLastUsedAt: String?
    let savedMusicIds: String?
    let appLanguage: String?
    let secondaryLanguage: String?
    let thirdLanguage: String?
    let defaultVideoQuality: String?
    let dataSaver: Bool?
    let disableAutoplay: Bool?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let provider: String?
    let providerId: String?
    let zodiacImageUrl: String?
    var profilePhotoSliderEnabled: Bool?
    var avatars: [UserAvatarModel]?
    let isFollowing: Bool?
    let followStatus: Int?
    let isBlock: Bool?
    let socialLinks: [SocialLinkModel]?
    
    /// Login
    var newRegister: Bool?
    var onboardingCompleted: Bool?
    var onboardingRequired: Bool?
    let token: TokenModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isDummy = "is_dummy"
        case identity
        case fullname
        case username
        case usernameUpdatedAt = "username_updated_at"
        case userEmail = "user_email"
        case emailVerifiedAt = "email_verified_at"
        case gender
        case dateOfBirth = "date_of_birth"
        case zodiac
//        case mobileCountryCode = "mobile_country_code"
        case userMobileNo = "user_mobile_no"
        case phoneVerifiedAt = "phone_verified_at"
        case profilePhoto = "profile_photo"
        case loginMethod = "login_method"
        case authMode = "auth_mode"
        case device
        case deviceToken = "device_token"
        case notifyPostLike = "notify_post_like"
        case notifyPostComment = "notify_post_comment"
        case notifyFollow = "notify_follow"
        case notifyMention = "notify_mention"
        case notifyGiftReceived = "notify_gift_received"
        case notifyChat = "notify_chat"
        case isVerify = "is_verify"
        case whoCanViewPost = "who_can_view_post"
        case showMyFollowing = "show_my_following"
        case receiveMessage = "receive_message"
        case receiveGiftsEnabled = "receive_gifts_enabled"
        case coinWallet = "coin_wallet"
        case bio
        case followerCount = "follower_count"
        case followingCount = "following_count"
        case friendsCount = "friends_count"
        case totalPostLikesCount = "total_post_likes_count"
        case isFreez = "is_freez"
        case startFreezeAt = "start_freeze_at"
        case endFreezeAt = "end_freeze_at"
        case country
        case countryCode
        case region
        case regionName
        case city
        case postalCode = "postal_code"
        case lat
        case lon
        case timezone
        case appLastUsedAt = "app_last_used_at"
        case savedMusicIds = "saved_music_ids"
        case appLanguage = "app_language"
        case secondaryLanguage = "secondary_language"
        case thirdLanguage = "third_language"
        case defaultVideoQuality = "default_video_quality"
        case dataSaver = "data_saver"
        case disableAutoplay = "disable_autoplay"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case provider
        case providerId = "provider_id"
        case zodiacImageUrl = "zodiac_image_url"
        case profilePhotoSliderEnabled = "profile_photo_slider_enabled"
        case avatars
        case isFollowing = "is_following"
        case followStatus = "follow_status"
        case isBlock = "is_block"
        case socialLinks = "social_links"
        
        /// Login
        case newRegister = "new_register"
        case onboardingCompleted = "onboarding_completed"
        case onboardingRequired = "onboarding_required"
        case token
    }
}

// MARK: - Token
struct TokenModel: Codable {
    let userId: String?
    let authToken: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case authToken = "auth_token"
    }
}

// MARK: - Avatar
struct UserAvatarModel: Codable, Equatable {
    let id: Int?
    let path: String?
    let url: String?
    var isPrimary: Bool?
    let sortOrder: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case path
        case url
        case isPrimary = "is_primary"
        case sortOrder = "sort_order"
    }
}

// MARK: - Social Link
struct SocialLinkModel: Codable {
    let id: Int?
    let userId: Int?
    let title: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case url
    }
}
