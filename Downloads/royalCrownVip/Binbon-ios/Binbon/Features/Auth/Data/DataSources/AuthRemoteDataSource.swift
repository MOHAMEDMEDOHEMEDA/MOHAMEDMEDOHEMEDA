//
//  AuthRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for authentication. Returns the raw response
//  envelope (`BaseResponse`); unwrapping, session persistence and error policy
//  live in `AuthRepositoryImpl`.
//
//  Current phase: backed by `MockAuthRemoteDataSource`. When the live API comes
//  online, add a `RemoteAuthDataSource` that calls `Network.shared.call(AuthAPIEndpoint…)`
//  and swap it in the DI factory — nothing above this boundary changes.
//

import Foundation

protocol AuthRemoteDataSource {
    func login(request: LoginUserRequest) async throws -> BaseResponse<UserResponse>
    func register(request: RegisterUserRequest) async throws -> BaseResponse<UserResponse>
    func sendOtp(email: String) async throws -> BaseResponse<EmptyResponse>
    func verifyOtp(email: String, otp: String) async throws -> BaseResponse<EmptyResponse>
    func socialLogin(provider: SocialProvider, token: String) async throws -> BaseResponse<UserResponse>
}

// MARK: - Mock

/// Mock transport used during the current pre-integration phase. Decodes a canned
/// user envelope so the auth flow is fully exercisable without the network.
struct MockAuthRemoteDataSource: AuthRemoteDataSource {

    func login(request: LoginUserRequest) async throws -> BaseResponse<UserResponse> {
        try Self.decode(Self.userEnvelope)
    }

    func register(request: RegisterUserRequest) async throws -> BaseResponse<UserResponse> {
        try Self.decode(Self.userEnvelope)
    }

    func sendOtp(email: String) async throws -> BaseResponse<EmptyResponse> {
        BaseResponse(status: true, message: "OK", data: EmptyResponse())
    }

    func verifyOtp(email: String, otp: String) async throws -> BaseResponse<EmptyResponse> {
        BaseResponse(status: true, message: "OK", data: EmptyResponse())
    }

    func socialLogin(provider: SocialProvider, token: String) async throws -> BaseResponse<UserResponse> {
        try Self.decode(Self.userEnvelope)
    }

    // MARK: - Helpers

    private static func decode<T: Decodable>(_ json: String) throws -> BaseResponse<T> {
        guard let data = json.data(using: .utf8) else {
            throw APIError(type: .parsing, message: "Invalid mock JSON")
        }
        do {
            return try JSONDecoder().decode(BaseResponse<T>.self, from: data)
        } catch {
            throw APIError(type: .parsing, message: "\(error)")
        }
    }

    /// `BaseResponse<UserResponse>` — token lives under `data.token.auth_token`.
    private static let userEnvelope = #"""
    {
      "status": true,
      "message": "OK",
      "data": {
        "id": 1001,
        "is_dummy": 0,
        "identity": "usr_1001",
        "fullname": "Mona Khalil",
        "username": "mona.k",
        "username_updated_at": "2026-01-12T09:30:00Z",
        "user_email": "mona@example.com",
        "email_verified_at": "2026-01-10T08:00:00Z",
        "gender": "female",
        "date_of_birth": "1996-04-22",
        "zodiac": "Taurus",
        "user_mobile_no": "+201001234567",
        "phone_verified_at": "2026-01-10T08:05:00Z",
        "profile_photo": "https://picsum.photos/seed/mona/300",
        "login_method": "email",
        "auth_mode": "password",
        "device": 1,
        "device_token": "dev_token_abc123",
        "notify_post_like": 1,
        "notify_post_comment": 1,
        "notify_follow": 1,
        "notify_mention": 1,
        "notify_gift_received": 1,
        "notify_chat": 1,
        "is_verify": 1,
        "who_can_view_post": 0,
        "show_my_following": 1,
        "receive_message": 1,
        "receive_gifts_enabled": 1,
        "coin_wallet": 4200,
        "bio": "Coffee, code and cats.",
        "follower_count": 1280,
        "following_count": 342,
        "total_post_likes_count": 9876,
        "is_freez": 0,
        "start_freeze_at": null,
        "end_freeze_at": null,
        "country": "Egypt",
        "countryCode": "EG",
        "region": "C",
        "regionName": "Cairo Governorate",
        "city": "Cairo",
        "postal_code": "11511",
        "lat": 30.0444,
        "lon": 31.2357,
        "timezone": "Africa/Cairo",
        "app_last_used_at": "2026-06-14T20:11:00Z",
        "saved_music_ids": "12,45,98",
        "app_language": "en",
        "secondary_language": "ar",
        "third_language": null,
        "default_video_quality": "auto",
        "data_saver": false,
        "disable_autoplay": false,
        "created_at": "2026-01-10T08:00:00Z",
        "updated_at": "2026-06-14T20:11:00Z",
        "deleted_at": null,
        "provider": null,
        "provider_id": null,
        "zodiac_image_url": "https://picsum.photos/seed/taurus/120",
        "profile_photo_slider_enabled": true,
        "avatars": [
          {
            "id": 1,
            "path": "avatars/mona-1.jpg",
            "url": "https://picsum.photos/seed/mona1/300",
            "is_primary": true,
            "sort_order": 0
          },
          {
            "id": 2,
            "path": "avatars/mona-2.jpg",
            "url": "https://picsum.photos/seed/mona2/300",
            "is_primary": false,
            "sort_order": 1
          }
        ],
        "is_following": false,
        "follow_status": 0,
        "is_block": false,
        "social_links": [
          {
            "id": 1,
            "user_id": 1001,
            "title": "instagram",
            "url": "https://instagram.com/mona.k"
          }
        ],
        "new_register": false,
        "onboarding_completed": true,
        "onboarding_required": false,
        "token": {
          "user_id": "1001",
          "auth_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMDAxIiwibmFtZSI6Ik1vbmEgS2hhbGlsIiwiaWF0IjoxNzE4MzAwMDAwfQ.dummysignatureforlocalmockonlyxxxx"
        }
      }
    }
    """#
}
