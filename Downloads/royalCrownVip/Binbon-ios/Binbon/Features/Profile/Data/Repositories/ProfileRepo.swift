//
//  ProfileRepo.swift
//  Binbon
//
//  Created by Salah Khaled on 02/03/2026.
//

import UIKit

class ProfileRepo: Repo {

    func fetchUserDetails() async -> Result<BaseResponse<UserResponse>, APIError> {
        let result: Result<BaseResponse<UserResponse>, APIError> = decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "id":101,
            "is_dummy":0,
            "identity":"BINBON-101",
            "fullname":"Maya Carter",
            "username":"maya.carter",
            "username_updated_at":"2026-05-01T10:15:00Z",
            "user_email":"maya.carter@example.com",
            "email_verified_at":"2026-04-20T08:00:00Z",
            "gender":"female",
            "date_of_birth":"1996-07-14",
            "zodiac":"Cancer",
            "user_mobile_no":"+15551234567",
            "phone_verified_at":"2026-04-21T09:30:00Z",
            "profile_photo":"https://picsum.photos/seed/101/200",
            "login_method":"email",
            "auth_mode":"standard",
            "device":1,
            "device_token":"mock-device-token-101",
            "notify_post_like":1,
            "notify_post_comment":1,
            "notify_follow":1,
            "notify_mention":1,
            "notify_gift_received":1,
            "notify_chat":1,
            "is_verify":1,
            "who_can_view_post":0,
            "show_my_following":1,
            "receive_message":1,
            "receive_gifts_enabled":1,
            "coin_wallet":1250,
            "bio":"Designer, coffee lover and weekend hiker.",
            "follower_count":1842,
            "following_count":318,
            "total_post_likes_count":9421,
            "is_freez":0,
            "start_freeze_at":null,
            "end_freeze_at":null,
            "country":"United States",
            "countryCode":"US",
            "region":"CA",
            "regionName":"California",
            "city":"San Francisco",
            "postal_code":"94103",
            "lat":37.7749,
            "lon":-122.4194,
            "timezone":"America/Los_Angeles",
            "app_last_used_at":"2026-06-14T18:45:00Z",
            "saved_music_ids":"12,45,78",
            "app_language":"en",
            "secondary_language":"es",
            "third_language":null,
            "default_video_quality":"auto",
            "data_saver":false,
            "disable_autoplay":false,
            "created_at":"2026-01-10T12:00:00Z",
            "updated_at":"2026-06-14T18:45:00Z",
            "deleted_at":null,
            "provider":null,
            "provider_id":null,
            "zodiac_image_url":"https://picsum.photos/seed/zodiac101/200",
            "profile_photo_slider_enabled":true,
            "avatars":[
                {"id":1,"path":"avatars/101_1.jpg","url":"https://picsum.photos/seed/avatar1011/200","is_primary":true,"sort_order":0},
                {"id":2,"path":"avatars/101_2.jpg","url":"https://picsum.photos/seed/avatar1012/200","is_primary":false,"sort_order":1},
                {"id":3,"path":"avatars/101_3.jpg","url":"https://picsum.photos/seed/avatar1013/200","is_primary":false,"sort_order":2}
            ],
            "is_following":false,
            "follow_status":0,
            "is_block":false,
            "social_links":[
                {"id":1,"user_id":101,"title":"Instagram","url":"https://instagram.com/maya.carter"},
                {"id":2,"user_id":101,"title":"Website","url":"https://mayacarter.example.com"}
            ],
            "new_register":false,
            "onboarding_completed":true,
            "onboarding_required":false,
            "token":{"user_id":"101","auth_token":"mock-auth-token-101"}
        }}
        """#)

        /// 📂 Update Storage
        if case .success(let response) = result {
            Storage.shared.user = response.data
        }

        return result
    }

    func updateUserDetails(request: EditProfileRequest) async -> Result<BaseResponse<UserResponse>, APIError> {
        let result: Result<BaseResponse<UserResponse>, APIError> = decodeMock(#"""
        {"status":true,"message":"Profile updated","data":{
            "id":101,
            "is_dummy":0,
            "identity":"BINBON-101",
            "fullname":"Maya Carter",
            "username":"maya.carter",
            "username_updated_at":"2026-06-15T11:00:00Z",
            "user_email":"maya.carter@example.com",
            "email_verified_at":"2026-04-20T08:00:00Z",
            "gender":"female",
            "date_of_birth":"1996-07-14",
            "zodiac":"Cancer",
            "user_mobile_no":"+15551234567",
            "phone_verified_at":"2026-04-21T09:30:00Z",
            "profile_photo":"https://picsum.photos/seed/101/200",
            "login_method":"email",
            "auth_mode":"standard",
            "device":1,
            "device_token":"mock-device-token-101",
            "notify_post_like":1,
            "notify_post_comment":1,
            "notify_follow":1,
            "notify_mention":1,
            "notify_gift_received":1,
            "notify_chat":1,
            "is_verify":1,
            "who_can_view_post":0,
            "show_my_following":1,
            "receive_message":1,
            "receive_gifts_enabled":1,
            "coin_wallet":1250,
            "bio":"Updated bio: building things and chasing sunsets.",
            "follower_count":1842,
            "following_count":318,
            "total_post_likes_count":9421,
            "is_freez":0,
            "start_freeze_at":null,
            "end_freeze_at":null,
            "country":"United States",
            "countryCode":"US",
            "region":"CA",
            "regionName":"California",
            "city":"San Francisco",
            "postal_code":"94103",
            "lat":37.7749,
            "lon":-122.4194,
            "timezone":"America/Los_Angeles",
            "app_last_used_at":"2026-06-15T11:00:00Z",
            "saved_music_ids":"12,45,78",
            "app_language":"en",
            "secondary_language":"es",
            "third_language":null,
            "default_video_quality":"auto",
            "data_saver":false,
            "disable_autoplay":false,
            "created_at":"2026-01-10T12:00:00Z",
            "updated_at":"2026-06-15T11:00:00Z",
            "deleted_at":null,
            "provider":null,
            "provider_id":null,
            "zodiac_image_url":"https://picsum.photos/seed/zodiac101/200",
            "profile_photo_slider_enabled":true,
            "avatars":[
                {"id":1,"path":"avatars/101_1.jpg","url":"https://picsum.photos/seed/avatar1011/200","is_primary":true,"sort_order":0},
                {"id":2,"path":"avatars/101_2.jpg","url":"https://picsum.photos/seed/avatar1012/200","is_primary":false,"sort_order":1}
            ],
            "is_following":false,
            "follow_status":0,
            "is_block":false,
            "social_links":[
                {"id":1,"user_id":101,"title":"Instagram","url":"https://instagram.com/maya.carter"}
            ],
            "new_register":false,
            "onboarding_completed":true,
            "onboarding_required":false,
            "token":{"user_id":"101","auth_token":"mock-auth-token-101"}
        }}
        """#)

        /// 📂 Update Storage
        if case .success(let response) = result {
            Storage.shared.user = response.data
        }

        return result
    }

    func recommendedUsers(limit: Int) async -> Result<BaseResponse<[RecommendUserResponse]>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":[
            {"id":201,"fullname":"Liam Nguyen","username":"liam.ng","profile_photo":"https://picsum.photos/seed/201/200","user_email":"liam.ng@example.com","bio":"Photographer & traveler."},
            {"id":202,"fullname":"Sofia Rossi","username":"sofia.rossi","profile_photo":"https://picsum.photos/seed/202/200","user_email":"sofia.rossi@example.com","bio":"Music producer."},
            {"id":203,"fullname":"Noah Patel","username":"noah.patel","profile_photo":"https://picsum.photos/seed/203/200","user_email":"noah.patel@example.com","bio":"Runner, foodie, dog dad."},
            {"id":204,"fullname":"Emma Johansson","username":"emma.j","profile_photo":"https://picsum.photos/seed/204/200","user_email":"emma.j@example.com","bio":"Illustrator from Stockholm."},
            {"id":205,"fullname":"Kai Tanaka","username":"kai.tanaka","profile_photo":"https://picsum.photos/seed/205/200","user_email":"kai.tanaka@example.com","bio":"Indie game developer."}
        ]}
        """#)
    }

    func getFollowers() async -> Result<BaseResponse<[FollowUserResponse]>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":[
            {"id":401,"fullname":"Olivia Davis","username":"olivia.d","profile_photo":"https://picsum.photos/seed/401/200"},
            {"id":402,"fullname":"James Wilson","username":"james.w","profile_photo":"https://picsum.photos/seed/402/200"},
            {"id":403,"fullname":"Isabella Garcia","username":"bella.g","profile_photo":"https://picsum.photos/seed/403/200"},
            {"id":404,"fullname":"Benjamin Lee","username":"ben.lee","profile_photo":"https://picsum.photos/seed/404/200"},
            {"id":405,"fullname":"Charlotte Kim","username":"charlotte.k","profile_photo":"https://picsum.photos/seed/405/200"}
        ]}
        """#)
    }

    func getFollowing() async -> Result<BaseResponse<[FollowUserResponse]>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":[
            {"id":301,"fullname":"Ava Williams","username":"ava.w","profile_photo":"https://picsum.photos/seed/301/200"},
            {"id":302,"fullname":"Lucas Martin","username":"lucas.m","profile_photo":"https://picsum.photos/seed/302/200"},
            {"id":303,"fullname":"Mia Chen","username":"mia.chen","profile_photo":"https://picsum.photos/seed/303/200"},
            {"id":304,"fullname":"Ethan Brown","username":"ethan.b","profile_photo":"https://picsum.photos/seed/304/200"}
        ]}
        """#)
    }

    func updateProfilePhoto(image: UIImage) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }

    func followUser(userId: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }

    func unfollowUser(userId: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }

    func removeFollower(userId: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }

    func shareLink() async -> Result<BaseResponse<ShareLinkResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "username":"maya.carter",
            "share_url":"https://binbon.app/u/maya.carter",
            "deep_link":"binbon://user/maya.carter"
        }}
        """#)
    }

    // MARK: - Mock Helpers

    private func mockEmpty() -> Result<BaseResponse<EmptyResponse>, APIError> {
        .success(BaseResponse(status: true, message: "OK", data: EmptyResponse()))
    }

    private func decodeMock<T: Decodable>(_ json: String) -> Result<BaseResponse<T>, APIError> {
        guard let data = json.data(using: .utf8) else {
            return .failure(APIError(type: .parsing, message: "Invalid mock JSON"))
        }
        do {
            return .success(try JSONDecoder().decode(BaseResponse<T>.self, from: data))
        } catch {
            return .failure(APIError(type: .parsing, message: "\(error)"))
        }
    }
}
