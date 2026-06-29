//
//  SettingRepo.swift
//  Binbon
//
//  Created by Salah Khaled on 02/03/2026.
//

import UIKit

class SettingRepo: Repo, SettingRepoProtocol {
    
    func fetchProfileSetting() async -> Result<BaseResponse<AccountSettingResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "id":101,
            "username":"laura_quinn",
            "email":"laura.quinn@example.com",
            "phone":"+1 415 555 0192",
            "bio":"Coffee, code, and golden hour photos.",
            "gender":"female",
            "date_of_birth":"1996-04-18",
            "zodiac":"Aries",
            "location":{
                "country":"United States",
                "city":"San Francisco",
                "latitude":37.7749,
                "longitude":-122.4194
            },
            "avatar":{
                "avatar_id":501,
                "profile_photo":"avatars/501.jpg",
                "profile_photo_url":"https://picsum.photos/seed/501/200"
            },
            "avatars":[
                {"id":501,"path":"avatars/501.jpg","url":"https://picsum.photos/seed/501/200","is_primary":true,"sort_order":0},
                {"id":502,"path":"avatars/502.jpg","url":"https://picsum.photos/seed/502/200","is_primary":false,"sort_order":1},
                {"id":503,"path":"avatars/503.jpg","url":"https://picsum.photos/seed/503/200","is_primary":false,"sort_order":2}
            ],
            "social_links":{
                "hide_social_links":false,
                "items":[
                    {"id":1,"platform":"instagram","url":"https://instagram.com/laura_quinn"},
                    {"id":2,"platform":"twitter","url":"https://twitter.com/laura_quinn"},
                    {"id":3,"platform":"tiktok","url":"https://tiktok.com/@laura_quinn"}
                ]
            },
            "profile_photo_slider_enabled":true,
            "connected_devices":[
                {"id":1,"device_name":"iPhone 16 Pro","device_type":"ios","location":"San Francisco, US","is_active":true,"activity_status":"online","last_login_at":"2026-06-15 09:12:44"},
                {"id":2,"device_name":"MacBook Air","device_type":"web","location":"San Francisco, US","is_active":true,"activity_status":"active 2h ago","last_login_at":"2026-06-15 07:05:10"},
                {"id":3,"device_name":"iPad Pro","device_type":"ios","location":"Oakland, US","is_active":false,"activity_status":"offline","last_login_at":"2026-06-12 21:48:33"},
                {"id":4,"device_name":"Pixel 8","device_type":"android","location":"London, UK","is_active":false,"activity_status":"offline","last_login_at":"2026-06-08 14:22:01"}
            ]
        }}
        """#)
    }
    
    func uploadAvatar(image: UIImage) async -> Result<BaseResponse<UploadedAvatarResponse>, APIError> {
        decodeMock(#"{"status":true,"message":"OK","data":{}}"#)
    }
    
    func deleteAvatar(id: Int) async -> Result<BaseResponse<DeleteAvatarResponse>, APIError> {
        decodeMock(#"{"status":true,"message":"OK","data":{}}"#)
    }
    
    func deviceLogout(id: Int) async -> Result<BaseResponse<AccountSettingResponse>, APIError> {
        await fetchProfileSetting()
    }
    
    func deviceLogoutAll() async -> Result<BaseResponse<AccountSettingResponse>, APIError> {
        await fetchProfileSetting()
    }
    
    func addUserLink(request: AccountLinkRequest) async -> Result<BaseResponse<[AccountLinkRequest]>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":[
            {"id":1,"title":"Portfolio","url":"https://laura.design"},
            {"id":2,"title":"Newsletter","url":"https://laura.substack.com"},
            {"id":3,"title":"GitHub","url":"https://github.com/lauraquinn"}
        ]}
        """#)
    }
    
    func deleteUserLink(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func patchProfileSetting(request: SaveAccountRequest) async -> Result<BaseResponse<AccountSettingResponse>, APIError> {
        await fetchProfileSetting()
    }
    
    func showPrivacySetting() async -> Result<BaseResponse<PrivacySettingModel>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "id":1,
            "user_id":101,
            "profile_visibility":0,
            "online_time_visibility":1,
            "friend_request_privacy":0,
            "dm_privacy":1,
            "comment_privacy":0,
            "mention_privacy":1,
            "story_privacy":0,
            "share_post_privacy":0,
            "activity_status_visibility":1,
            "incognito_mode":false
        }}
        """#)
    }
    
    func patchPrivacySetting(request: PrivacySettingModel) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func securitySetting() async -> Result<BaseResponse<SecuritySettingResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "two_factor_enabled":true,
            "two_factor_channel":"email",
            "biometric_enabled":true,
            "biometric_type":"face_id",
            "biometric_methods":["face_id","touch_id"],
            "new_device_alerts_enabled":true,
            "recovery_codes_count":8
        }}
        """#)
    }
    
    func enable2FAuth(channel: String) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func disbale2FAuth(password: String) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func verify2FAuth(otp: String) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func updateBiometric(request: BiometricUpdateRequest) async -> Result<BaseResponse<SecuritySettingResponse>, APIError> {
        await securitySetting()
    }
    
    func securityActivity(page: Int) async -> Result<BaseResponse<SecurityActivityResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "groups":{
                "June 2026":[
                    {"activity_type":"login","description":"New sign in from iPhone 16 Pro","timestamp":"2026-06-15 09:12:44"},
                    {"activity_type":"biometric_updated","description":"Face ID enabled","timestamp":"2026-06-14 18:30:02"},
                    {"activity_type":"password_changed","description":"Password updated","timestamp":"2026-06-10 11:05:50"}
                ],
                "May 2026":[
                    {"activity_type":"two_factor_enabled","description":"Two-factor authentication enabled","timestamp":"2026-05-28 16:44:21"},
                    {"activity_type":"new_device","description":"New device added: MacBook Air","timestamp":"2026-05-20 08:15:09"}
                ]
            },
            "pagination":{
                "current_page":1,
                "last_page":3,
                "per_page":15,
                "total":42
            }
        }}
        """#)
    }
    
    func loginHistory(page: Int) async -> Result<BaseResponse<LoginHistoryResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "items":[
                {"id":1,"device_name":"iPhone 16 Pro","ip":"73.158.12.44","location":"San Francisco, US","login_time":"2026-06-15 09:12:44","is_new_device":false},
                {"id":2,"device_name":"MacBook Air","ip":"73.158.12.44","location":"San Francisco, US","login_time":"2026-06-15 07:05:10","is_new_device":false},
                {"id":3,"device_name":"Pixel 8","ip":"81.2.69.142","location":"London, UK","login_time":"2026-06-08 14:22:01","is_new_device":true},
                {"id":4,"device_name":"iPad Pro","ip":"73.158.12.90","location":"Oakland, US","login_time":"2026-06-05 19:33:27","is_new_device":false},
                {"id":5,"device_name":"Windows PC","ip":"203.0.113.7","location":"Berlin, DE","login_time":"2026-05-29 10:48:12","is_new_device":true}
            ],
            "pagination":{
                "current_page":1,
                "last_page":2,
                "per_page":15,
                "total":18
            }
        }}
        """#)
    }
    
    func fetchContentControlSettings() async -> Result<BaseResponse<ContentControlSettings>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "content_types":{
            "available":[
              {"id":1,"name":"Sports","slug":"sports"},
              {"id":2,"name":"Music","slug":"music"},
              {"id":3,"name":"Comedy","slug":"comedy"},
              {"id":4,"name":"Technology","slug":"technology"},
              {"id":5,"name":"Travel","slug":"travel"}
            ],
            "selected":[
              {"id":2,"name":"Music","slug":"music"},
              {"id":4,"name":"Technology","slug":"technology"}
            ],
            "selected_category_ids":[2,4]
          },
          "age":{"is_under_18":false},
          "kids_mode":{"enabled":false},
          "safety":{
            "filter_inappropriate_content":true,
            "blocked_keywords":["spam","spoiler","gambling"],
            "blocked_keywords_text":"spam, spoiler, gambling"
          }
        }}
        """#)
    }
    
    func patchContentControlSettings(request: ContentControlUpdateRequest) async -> Result<BaseResponse<ContentControlSettings>, APIError> {
        await fetchContentControlSettings()
    }
    
    // MARK: - Live Stream
    func fetchLiveStreamSettings() async -> Result<BaseResponse<LiveStreamSettingResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "comments_enabled":true,
          "gifts_enabled":true,
          "live_visibility":1,
          "live_type":0,
          "live_password_enabled":false,
          "audience_filter":"friends",
          "items":[
            {"id":11,"username":"sara_h","fullname":"Sara Hassan","profile_photo":"https://i.pravatar.cc/150?img=5"},
            {"id":12,"username":"omar.k","fullname":"Omar Khaled","profile_photo":"https://i.pravatar.cc/150?img=12"},
            {"id":13,"username":"layla_m","fullname":"Layla Mahmoud","profile_photo":"https://i.pravatar.cc/150?img=20"}
          ],
          "pagination":{
            "current_page":1,
            "per_page":20,
            "total":3,
            "last_page":1
          },
          "visibility_options":[
            {"key":0,"label":"Everyone"},
            {"key":1,"label":"Friends"},
            {"key":2,"label":"Friends of friends"},
            {"key":3,"label":"No one"}
          ],
          "type_options":[
            {"key":0,"label":"Public"},
            {"key":1,"label":"Private"}
          ]
        }}
        """#)
    }
    
    func patchLiveStreamSettings(request: LiveStreamUpdateRequest) async -> Result<BaseResponse<LiveStreamSettingResponse>, APIError> {
        await fetchLiveStreamSettings()
    }
    
    func fetchLiveSchedules() async -> Result<BaseResponse<LiveScheduleListResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "items":[
            {
              "id":101,
              "title":"Friday Q&A Session",
              "scheduled_for":"2026-06-19T18:00:00+02:00",
              "timezone":"Africa/Cairo",
              "live_visibility":1,
              "live_type":0,
              "comments_enabled":true,
              "gifts_enabled":true,
              "invited_user_ids":[11,12]
            },
            {
              "id":102,
              "title":"New Album Listening Party",
              "scheduled_for":"2026-06-22T20:30:00+02:00",
              "timezone":"Africa/Cairo",
              "live_visibility":0,
              "live_type":0,
              "comments_enabled":true,
              "gifts_enabled":false,
              "invited_user_ids":[]
            },
            {
              "id":103,
              "title":"Subscribers-Only Workshop",
              "scheduled_for":"2026-06-25T16:00:00+02:00",
              "timezone":"Africa/Cairo",
              "live_visibility":3,
              "live_type":1,
              "comments_enabled":false,
              "gifts_enabled":true,
              "invited_user_ids":[13]
            }
          ]
        }}
        """#)
    }
    
    func createLiveSchedule(request: LiveScheduleRequest) async -> Result<BaseResponse<LiveSchedule>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "id":101,
          "title":"Friday Q&A Session",
          "scheduled_for":"2026-06-19T18:00:00+02:00",
          "timezone":"Africa/Cairo",
          "live_visibility":1,
          "live_type":0,
          "comments_enabled":true,
          "gifts_enabled":true,
          "invited_user_ids":[11,12]
        }}
        """#)
    }
    
    func deleteLiveSchedule(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func fetchSettingsUserDataStorage() async -> Result<BaseResponse<DataStorageSettingsResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "storage":{
            "cache_size_mb":248.5,
            "total_storage_mb":64000
          },
          "video_download":{
            "default_quality":"720p",
            "effective_quality":"720p",
            "allowed_qualities":["360p","480p","720p","1080p"]
          },
          "data_saver":{
            "enabled":false,
            "disable_autoplay":true
          },
          "actions":{
            "clear_cache_endpoint":"api/user/settings/data-storage/clear-cache",
            "personal_data_export_endpoint":"api/user/settings/data-storage/export",
            "delete_account_endpoint":"api/user/settings/data-storage/delete-account"
          }
        }}
        """#)
    }
    
    func patchSettingsUserDataStorage(request: UpdateDataStorageSettingsRequest) async -> Result<BaseResponse<DataStorageSettingsResponse>, APIError> {
        await fetchSettingsUserDataStorage()
    }
    
    func clearCache() async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func deleteMyAccount() async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func fetchStorySettings() async -> Result<BaseResponse<StorySettingsResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "story_visibility":"friends",
          "story_reply_permissions":"everyone",
          "auto_save_stories":true,
          "share_to_other_accounts":false
        }}
        """#)
    }
    
    func patchStorySettings(request: StorySettingsRequest) async -> Result<BaseResponse<StorySettingsResponse>, APIError> {
        await fetchStorySettings()
    }
    
    func exportPersonalData() async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func fetchSupportFaqs() async -> Result<BaseResponse<[SupportFAQ]>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":[
          {
            "id":1,
            "title":"How do I reset my password?",
            "subtitle":"Account & security",
            "description":"Open Settings, tap Security, then Change Password. Enter your current password followed by the new one. If you forgot your current password, use the Forgot Password link on the login screen to receive a reset code by email."
          },
          {
            "id":2,
            "title":"Why can't I go live?",
            "subtitle":"Live streaming",
            "description":"Live streaming requires a verified account and at least 50 followers. Make sure your account is in good standing and that you have granted camera and microphone permissions to the app in your device settings."
          },
          {
            "id":3,
            "title":"How do I report inappropriate content?",
            "subtitle":"Safety",
            "description":"Tap the three-dot menu on any post, story, or live stream and choose Report. Select the reason that best matches the issue. Our moderation team reviews every report, usually within 24 hours."
          },
          {
            "id":4,
            "title":"Can I download my data?",
            "subtitle":"Privacy",
            "description":"Yes. Go to Settings, then Data & Storage, and tap Export Personal Data. We will prepare a downloadable archive of your account information and notify you by email when it is ready."
          },
          {
            "id":5,
            "title":"How do I delete my account?",
            "subtitle":"Account",
            "description":"Account deletion is permanent. In Settings, open Data & Storage and select Delete Account. You will be asked to confirm with your password. All your posts, messages, and followers will be removed and cannot be recovered."
          }
        ]}
        """#)
    }
    
    func sendSuggestion(message: String) async -> Result<BaseResponse<SupportSuggestion>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "id":5001,
          "user_id":42,
          "message":"It would be great to add a dark mode schedule that follows sunset.",
          "created_at":"2026-06-15T10:24:00+02:00",
          "updated_at":"2026-06-15T10:24:00+02:00"
        }}
        """#)
    }
    
    func sendReport(message: String) async -> Result<BaseResponse<SupportTicket>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "id":7001,
          "user_id":42,
          "problem_description":"The video player keeps buffering on cellular data even with high quality disabled.",
          "attachment":null,
          "attachment_url":null,
          "status":"open",
          "created_at":"2026-06-15T10:30:00+02:00",
          "updated_at":"2026-06-15T10:30:00+02:00"
        }}
        """#)
    }
    
    func interactionSetting() async -> Result<BaseResponse<InteractionSettings>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "allow_comments":true,
            "comments_permission":"friends",
            "allow_media_messages":true,
            "media_messages_permission":"everyone",
            "mentions_permission":"friends_of_friends"
        }}
        """#)
    }
    
    func updateInteractionSettings(updateInteractionSettings: UpdateInteractionSettings) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func fetchBlockedUsers(request: BlockedUsersRequest) async -> Result<BlockedUsersResponse, APIError> {
        decodeMockRaw(#"""
        {
            "status":true,
            "message":"OK",
            "data":[
                {"id":201,"username":"spam_account","fullname":"Spam Account","profile_photo":"https://picsum.photos/seed/201/200","blocked_at":"2026-06-01 12:00:00"},
                {"id":202,"username":"troll_user","fullname":"Troll User","profile_photo":"https://picsum.photos/seed/202/200","blocked_at":"2026-05-22 18:30:00"},
                {"id":203,"username":"ex_follower","fullname":"Former Follower","profile_photo":"https://picsum.photos/seed/203/200","blocked_at":"2026-05-10 09:15:00"},
                {"id":204,"username":"bot_42","fullname":"Bot Forty-Two","profile_photo":null,"blocked_at":"2026-04-28 14:05:00"}
            ],
            "meta":{
                "type":"cursor",
                "per_page":15,
                "next_cursor":null,
                "prev_cursor":null,
                "has_more":false
            }
        }
        """#)
    }
    
    func blockUser(username: String) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func unblockUser(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError> {
        mockEmpty()
    }
    
    func fetchLegalSettings() async -> Result<BaseResponse<LegalContent>, APIError> {
        let isArabic = Localizer.shared.language == .arabic
        let termsSections = isArabic ? termsSectionsArabic : termsSectionsEnglish
        let privacySections = isArabic ? privacySectionsArabic : privacySectionsEnglish
        let fairUseSections = isArabic ? fairUseSectionsArabic : fairUseSectionsEnglish
        let ipRightsSections = isArabic ? ipRightsSectionsArabic : ipRightsSectionsEnglish
        let dataDeletionSections = isArabic ? dataDeletionSectionsArabic : dataDeletionSectionsEnglish
        return decodeMock(#"""
        {"status":true,"message":"OK","data":{
          "menu":[
            {"slug":"terms_and_conditions","title":"Terms & Conditions","endpoint":"api/user/legal/terms"},
            {"slug":"privacy_policy","title":"Privacy Policy","endpoint":"api/user/legal/privacy"},
            {"slug":"intellectual_property_rights","title":"Intellectual Property Rights","endpoint":"api/user/legal/ip"},
            {"slug":"fair_use_policy","title":"Fair Use Policy","endpoint":"api/user/legal/fair-usage"},
            {"slug":"data_deletion_request","title":"Data deletion request","endpoint":"api/user/legal/data-deletion"}
          ],
        "terms_and_conditions": {
          "slug": "terms_and_conditions",
          "title": "Terms & Conditions",
          "sections": \#(termsSections)
        },
        "privacy_policy": {
          "slug": "privacy_policy",
          "title": "Privacy Policy",
          "sections": \#(privacySections)
        },
        "intellectual_property_rights": {
          "slug": "intellectual_property_rights",
          "title": "Intellectual Property Rights",
          "sections": \#(ipRightsSections)
        },
        "fair_use_policy": {
          "slug": "fair_use_policy",
          "title": "Fair Use Policy",
          "sections": \#(fairUseSections)
        },
        "data_deletion_request": {
          "slug": "data_deletion_request",
          "title": "Data deletion request",
          "sections": \#(dataDeletionSections)
        }
        }}
        """#)
    }
    
    // MARK: - Ads Settings
    
    func fetchAdsSettings() async -> Result<BaseResponse<AdsSettingResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{
            "ad_types":[
                {"id":1,"key":"sponsored_long_video","title":"sponsored_ad_long_video","enabled":true},
                {"id":2,"key":"sponsored_short_video","title":"sponsored_ad_short_video","enabled":true},
                {"id":3,"key":"sponsored_product","title":"sponsored_ad_product","enabled":false},
                {"id":4,"key":"sponsored_story","title":"sponsored_ad_story","enabled":true},
                {"id":5,"key":"sponsored_live_streaming","title":"sponsored_ad_live_streaming","enabled":false}
            ]
        }}
        """#)
    }
    
    func patchAdsSettings(request: AdsSettingRequest) async -> Result<BaseResponse<AdsSettingResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"Ads settings updated","data":{
            "ad_types":[
                {"id":1,"key":"sponsored_long_video","title":"sponsored_ad_long_video","enabled":true},
                {"id":2,"key":"sponsored_short_video","title":"sponsored_ad_short_video","enabled":true},
                {"id":3,"key":"sponsored_product","title":"sponsored_ad_product","enabled":false},
                {"id":4,"key":"sponsored_story","title":"sponsored_ad_story","enabled":true},
                {"id":5,"key":"sponsored_live_streaming","title":"sponsored_ad_live_streaming","enabled":false}
            ]
        }}
        """#)
    }

    // MARK: - Terms & Conditions localized mock sections

    private var termsSectionsArabic: String {
        #"""
        [
          {"id":1,"title":"الموافقة على الشروط","content":"باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق."},
          {"id":2,"title":"أهلية الاستخدام","content":"لا يجوز استخدام التطبيق إلا من قبل الأشخاص الذين تبلغ أعمارهم 13 عامًا فأكثر. إذا كان عمرك أقل من 18 عامًا، يرجى الحصول على إذن من ولي أمرك."},
          {"id":3,"title":"إنشاء الحساب","content":"يجب عليك تقديم معلومات صحيحة وكاملة عند إنشاء حسابك. لا يسمح بانتحال شخصية أي شخص أو جهة. أنت مسؤول عن الحفاظ على سرية بيانات الدخول لحسابك."},
          {"id":4,"title":"المحتوى الذي تنشره","content":"أنت تحتفظ بحقوق الملكية لمحتواك، لكنك تمنحنا ترخيصًا غير حصري لاستخدامه داخل التطبيق لأغراض الترويج والتشغيل.\nيمنع نشر محتوى يحتوي على:\n• عنف أو كراهية أو تمييز.\n• مواد إباحية أو محتوى غير لائق.\n• معلومات كاذبة أو مضللة.\n• حقوق ملكية فكرية لا تملكها."},
          {"id":5,"title":"السلوك المحظور","content":"يُمنع عليك:\n• مضايقة المستخدمين الآخرين.\n• استخدام التطبيق لأغراض غير قانونية.\n• محاولة اختراق، تعطيل، أو التلاعب بأنظمة التطبيق.\n• استخدام روبوتات أو أدوات تلقائية بدون إذن."},
          {"id":6,"title":"حقوق الملكية الفكرية","content":"جميع حقوق التصميم، البرمجيات، الشعارات، وواجهات الاستخدام محفوظة لنا. لا يجوز إعادة استخدام أي جزء من التطبيق بدون إذن كتابي مسبق."},
          {"id":7,"title":"الإعلانات والمشتريات داخل التطبيق","content":"قد يحتوي التطبيق على إعلانات. عند شراء أي منتج أو خدمة، فإنك توافق على الأسعار والشروط المعلنة."},
          {"id":8,"title":"إنهاء الحساب","content":"نحتفظ بالحق في تعليق أو حذف حسابك في حال انتهاكك لأي من الشروط دون إشعار مسبق."},
          {"id":9,"title":"تعديل الشروط","content":"نحتفظ بحق تعديل هذه الشروط في أي وقت. سيتم إشعارك بالتعديلات داخل التطبيق. استمرارك في استخدام التطبيق يعني موافقتك على التعديلات."},
          {"id":10,"title":"سياسة الخصوصية","content":"يرجى مراجعة [سياسة الخصوصية] لفهم كيفية تعاملنا مع معلوماتك الشخصية."},
          {"id":11,"title":"القانون الواجب التطبيق","content":"تخضع هذه الشروط لقوانين [اكتب اسم الدولة أو الولاية]. ويكون القضاء المختص هو [حدد المدينة أو المحكمة]."}
        ]
        """#
        }
        
        private var termsSectionsEnglish: String {
        #"""
        [
          {"id":1,"title":"Acceptance of Terms","content":"By using the application, you agree to comply with these Terms and Conditions. If you do not agree with any part of these terms, please do not use the application."},
          {"id":2,"title":"Eligibility","content":"The application may not be used by individuals under the age of 13. If you are under 18 years old, you must obtain permission from your parent or legal guardian."},
          {"id":3,"title":"Account Creation","content":"You must provide accurate and complete information when creating your account.\nDo not transfer or share your account with anyone else.\nYou are responsible for maintaining the confidentiality of your login credentials."},
          {"id":4,"title":"Content You Post","content":"You retain ownership of the content you post, but you grant us the right to display and use it within the application.\nThe following content is prohibited:\n• Hate speech or bullying.\n• Pornographic or inappropriate material.\n• False or misleading information.\n• Content that infringes the intellectual property rights of others."},
          {"id":5,"title":"Prohibited Conduct","content":"You may not:\n• Harass other users.\n• Use the application for illegal purposes.\n• Attempt to hack, disrupt, or interfere with the application.\n• Use bots or automated tools without authorization."},
          {"id":6,"title":"Intellectual Property Rights","content":"All designs, logos, trademarks, and application content are owned by us. No part of the application may be copied, reused, or distributed without prior written permission."},
          {"id":7,"title":"Advertisements and In-App Purchases","content":"The application may contain advertisements or offer in-app purchases. By completing a purchase, you agree to the displayed prices and applicable terms."},
          {"id":8,"title":"Account Termination","content":"We reserve the right to suspend or terminate your account if you violate these Terms and Conditions, with or without prior notice."},
          {"id":9,"title":"Changes to the Terms","content":"We reserve the right to modify these Terms and Conditions at any time. You will be notified of updates within the application, and your continued use of the application constitutes acceptance of the revised terms."},
          {"id":10,"title":"Privacy Policy","content":"Please review our Privacy Policy to understand how we collect, use, and protect your personal information."},
          {"id":11,"title":"Governing Law","content":"These Terms and Conditions are governed by the laws applicable in the country where the application operates, and disputes shall be subject to the jurisdiction of the competent courts."}
        ]
        """#
        }
        
        // MARK: - Privacy Policy localized mock sections
        
        private var privacySectionsArabic: String {
        #"""
        [
          {"id":1,"title":"","content":"نحن بنحترم خصوصيتك، ومالتزمون بحماية البيانات الشخصية التي تقدمها لنا. سياسة الخصوصية دي بتوضح إزاي بنجمع، نستخدم، ونشارك معلوماتك."},
          {"id":2,"title":"معلومات بتدخلها بإيدك:","content":"• الاسم أو اسم المستخدم\n• البريد الإلكتروني أو رقم الموبايل\n• صورة البروفايل، السيرة الذاتية\n• الفيديوهات اللي بترفعها أو التعليقات اللي معاها"},
          {"id":3,"title":"معلومات بنجمعها تلقائيًا:","content":"• نوع الجهاز ونظام التشغيل\n• عنوان الـ IP\n• الموقع الجغرافي (لو مفعل)\n• بيانات الاستخدام (إزاي الوقت اللي بتقضيه، الفيديوهات اللي بتشوفها، إزاي بتضغطها)"},
          {"id":4,"title":"إزاي بنستخدم معلوماتك؟","content":"• للتشغيل وتحسين التطبيق\n• لتخصيص المحتوى حسب تفضيلاتك\n• لحمايتك ومنع الاحتيال أو إساءة الاستخدام\n• للتواصل معاك بخصوص تحديثات أو إشعارات مهمة\n• لأغراض تسويقية (بموافقتك)"},
          {"id":5,"title":"هل بنشارك معلوماتك مع أطراف تانية؟","content":"ما بنشاركش معلوماتك مع أي طرف خارجي، إلا في الحالات دي:\n• شركاء تحليل البيانات أو تقديم الخدمات (بشروط سرية)\n• لو مطلوب قانوني (أمر محكمة أو تحقيق رسمي)\n• لو حصل اندماج أو بيع للشركة"},
          {"id":6,"title":"الكوكيز والتتبع","content":"ممكن نستخدم ملفات \"كوكيز\" أو أدوات مشابهة عشان نحسن تجربتك ونفهم سلوك المستخدمين."},
          {"id":7,"title":"حقوقك كمستخدم","content":"• من حقك تطلب نسخة من بياناتك\n• من حقك تطلب تعديل أو حذف بياناتك\n• من حقك ترفض أو توافق على استخدام معلوماتك في أي وقت\n(راسلنا على البريد الإلكتروني أدناه عشان تنفذ أي من حقوقك)"},
          {"id":8,"title":"أمان البيانات","content":"بنتبع إجراءات أمنية قوية لحماية معلوماتك، لكن ما فيش نظام آمن بنسبة 100% على الإنترنت."},
          {"id":9,"title":"خصوصية الأطفال","content":"التطبيق مش مخصص للأطفال تحت سن 13 سنة، ولو اكتشفنا إن في طفل سجل بدون إذن ولي أمره هندحف حسابه فورًا."},
          {"id":10,"title":"تعديلات على سياسة الخصوصية","content":"ممكن نحدث السياسة دي من وقت لتاني. هنبعت لك إشعار في حالة وجود تغييرات مهمة. استمرارك في استخدام التطبيق يعني موافقتك على التعديلات."}
        ]
        """#
        }
        
        private var privacySectionsEnglish: String {
        #"""
        [
          {"id":1,"title":"","content":"We respect your privacy and are committed to protecting the personal information you provide to us. This Privacy Policy explains how we collect, use, and share your information."},
          {"id":2,"title":"Information You Provide","content":"• Your name or username\n• Email address or mobile number\n• Profile picture, bio\n• Videos you upload or comments you make"},
          {"id":3,"title":"Information Collected Automatically","content":"• Device type and operating system\n• IP address\n• Geographic location (if enabled)\n• Usage data (time spent, videos watched, how you interact)"},
          {"id":4,"title":"How We Use Your Information","content":"• To operate and improve the application\n• To personalize content based on your preferences\n• To protect you and prevent fraud or misuse\n• To communicate updates or important notices\n• For marketing purposes (with your consent)"},
          {"id":5,"title":"Do We Share Your Information With Third Parties?","content":"We do not share your information with any third party, except in the following cases:\n• Data analytics or service partners (under confidentiality terms)\n• When legally required (court order or official investigation)\n• In the event of a merger or sale of the company"},
          {"id":6,"title":"Cookies and Tracking","content":"We may use \"cookies\" or similar tools to improve your experience and understand user behavior."},
          {"id":7,"title":"Your Rights as a User","content":"• You have the right to request a copy of your data\n• You have the right to request edit or deletion of your data\n• You have the right to accept or refuse the use of your information at any time\n(Email us at the address below to exercise any of these rights)"},
          {"id":8,"title":"Data Security","content":"We follow strong security measures to protect your information, but no system is 100% secure on the internet."},
          {"id":9,"title":"Children's Privacy","content":"The application is not intended for children under the age of 13. If we discover that a child has registered without parental consent, we will delete the account immediately."},
          {"id":10,"title":"Changes to This Privacy Policy","content":"We may update this policy from time to time. We will notify you of significant changes. Continued use of the application constitutes acceptance of the modifications."}
        ]
        """#
        }
        
        // MARK: - Fair Usage Policy localized mock sections
        
        private var fairUseSectionsArabic: String {
        #"""
        [
          {"id":1,"title":"السلوك المقبول","content":"إنت مسؤول عن كل المحتوى اللي بتنشره أو تتفاعل معاه. لازم تلتزم بالتالي:\n• احترام الآخرين وعدم الإساءة إليهم.\n• نشر محتوى قانوني ومحترم.\n• عدم التعدي على حقوق الملكية الفكرية لأي جهة أو شخص.\n• الامتناع عن نشر أو مشاركة أي محتوى مسيء أو ضار.","sort_order":1},
          {"id":2,"title":"المحتوى المحظور","content":"يُمنع تماماً نشر أو التفاعل مع أي من التالي:\n• محتوى عنف أو يحرض على الكراهية أو العنف.\n• محتوى جنسي صريح أو غير لائق.\n• تنمر أو مضايقة أو تهديد للآخرين.\n• معلومات كاذبة أو مضللة.\n• محتوى يحتوي على عنصرية أو تمييز.\n• ترويج لمخدرات، كحول، أو أسلحة.\n• روابط خارجية ضارة أو مشبوهة.","sort_order":2},
          {"id":3,"title":"الاستخدام التقني المقبول","content":"ماينفعش تستخدم التطبيق في أي تصرف تقني ضار زي:\n• محاولة اختراق التطبيق أو العبث بخدماته.\n• استخدام روبوتات أو سكريبتس تجمع البيانات أو إنشاء حسابات وهمية.\n• إبطاء أو تعطيل سيرفرات التطبيق بأي طريقة.","sort_order":3},
          {"id":4,"title":"عدد مرات النشر والتفاعل","content":"لحماية النظام من سوء الاستخدام:\n• يفضل عدم نشر عدد كبير من الفيديوهات خلال وقت قصير بطريقة عشوائية.\n• التفاعل بالإعجابات، تعليقات، متابعات، لازم يكون طبيعي وإنساني، مش آلي، أو لأغراض دعاية.","sort_order":4},
          {"id":5,"title":"العقوبات في حالة مخالفة السياسة","content":"لو خالفت سياسة الاستخدام العادل، ممكن تتصرف بالشكل التالي:\n• تنبيه أو تحذير أولي.\n• تقييد بعض الميزات مؤقتاً.\n• تعليق أو إغلاق الحساب نهائياً.\n• الإبلاغ عن المخالفات للجهات القانونية (في الحالات الخطورة).","sort_order":5},
          {"id":6,"title":"الإبلاغ عن المخالفات","content":"لو شفت أي محتوى أو سلوك مخالف، تقدر تستخدم ميزة \"الإبلاغ\" داخل التطبيق.\nبرجاء مراسلتنا.","sort_order":6},
          {"id":7,"title":"تحديثات السياسة","content":"من وقت لتاني، ممكن نحدث سياسة الاستخدام العادل. هنبعت لك إشعار في حالة وجود تغييرات مهمة.","sort_order":7}
        ]
        """#
        }
        
        private var fairUseSectionsEnglish: String {
        #"""
        [
          {"id":1,"title":"Acceptable Conduct","content":"You are responsible for all content you post or interact with. You must comply with the following:\n• Respect others and refrain from any abuse.\n• Post lawful, respectful content.\n• Do not infringe the intellectual property rights of any entity or person.\n• Refrain from posting or sharing any offensive or harmful content.","sort_order":1},
          {"id":2,"title":"Prohibited Content","content":"It is strictly prohibited to post or interact with any of the following:\n• Violent content or content that incites hate or violence.\n• Explicit or inappropriate sexual content.\n• Bullying, harassment, or threats toward others.\n• False or misleading information.\n• Content containing racism or discrimination.\n• Promotion of drugs, alcohol, or weapons.\n• Harmful or suspicious external links.","sort_order":2},
          {"id":3,"title":"Acceptable Technical Use","content":"You may not use the application for any harmful technical activity, such as:\n• Attempting to hack the application or tamper with its services.\n• Using bots or scripts to scrape data or create fake accounts.\n• Slowing down or disrupting the app's servers in any way.","sort_order":3},
          {"id":4,"title":"Posting and Interaction Frequency","content":"To protect the system from misuse:\n• Avoid posting a large number of videos in a short period in a random pattern.\n• Likes, comments, and follows must be natural and human, not automated or for promotional purposes.","sort_order":4},
          {"id":5,"title":"Penalties for Policy Violations","content":"If you violate the fair usage policy, action may be taken as follows:\n• An initial alert or warning.\n• Temporary restriction of some features.\n• Suspension or permanent closure of the account.\n• Reporting violations to legal authorities (in serious cases).","sort_order":5},
          {"id":6,"title":"Reporting Violations","content":"If you see any violating content or behavior, you can use the \"Report\" feature inside the app.\nPlease also contact us.","sort_order":6},
          {"id":7,"title":"Policy Updates","content":"From time to time, we may update the fair usage policy. We will notify you in case of significant changes.","sort_order":7}
        ]
        """#
        }
        
        // MARK: - Intellectual Property Rights localized mock sections
        
        private var ipRightsSectionsArabic: String {
        #"""
        [
          {"id":1,"title":"","content":"نحن نحترم حقوق الملكية الفكرية للآخرين، ونتوقع من مستخدمينا القيام بذلك أيضاً. تهدف هذه السياسة إلى حماية أصحاب الحقوق ومنع استخدام أو نشر أي محتوى ينتهك حقوق الملكية الفكرية داخل تطبيقنا."},
          {"id":2,"title":"المحتوى المقدم من المستخدمين","content":"يقر المستخدم عند رفع أي محتوى (مثل الفيديوهات أو الصوتيات أو الصور أو النصوص) بأنه:\n• يملك جميع الحقوق القانونية للمحتوى الذي يقوم بمشاركته؛ أو\n• حصل على جميع التراخيص أو الأذونات اللازمة لاستخدام هذا المحتوى داخل التطبيق.\n• يُمنع نشر أي محتوى ينتهك حقوق النشر، أو العلامات التجارية، أو الأسرار التجارية، أو حقوق المؤلفين، أو أي حقوق ملكية فكرية أخرى."},
          {"id":3,"title":"الإبلاغ عن الانتهاك","content":"إذا كنت مالكاً لحق ملكية فكرية وتعتقد أن هناك محتوى في التطبيق ينتهك هذا الحق، يمكنك إرسال بلاغ."},
          {"id":4,"title":"اتخاذ الإجراءات","content":"نحتفظ بحقنا في:\n• إزالة أو تعطيل الوصول إلى المحتوى المنتهك فوراً.\n• حظر حساب المستخدم المتكرر لانتهاكات الملكية الفكرية.\n• التعاون مع الجهات القانونية المختصة عند الحاجة."},
          {"id":5,"title":"إخلاء مسؤولية","content":"لسنا مسؤولين عن المحتوى الذي ينشره المستخدمون، لكننا نلتزم بالرد السريع على أي بلاغ قانوني موثق بشأن انتهاك حقوق الملكية الفكرية."}
        ]
        """#
        }
        
        private var ipRightsSectionsEnglish: String {
        #"""
        [
          {"id":1,"title":"","content":"We respect the intellectual property rights of others and expect our users to do the same. This policy aims to protect rights holders and prevent the use or posting of any content that infringes intellectual property rights within our application."},
          {"id":2,"title":"User-Submitted Content","content":"When uploading any content (such as videos, audio, images, or text), the user acknowledges that:\n• They own all legal rights to the content they share; or\n• They have obtained all necessary licenses or permissions to use this content within the application.\n• It is prohibited to post any content that infringes copyrights, trademarks, trade secrets, authors' rights, or any other intellectual property rights."},
          {"id":3,"title":"Reporting Infringement","content":"If you are an intellectual property rights holder and believe that content within the application infringes your rights, you can submit a report."},
          {"id":4,"title":"Enforcement Actions","content":"We reserve the right to:\n• Immediately remove or disable access to the infringing content.\n• Ban repeat infringer accounts for intellectual property violations.\n• Cooperate with the competent legal authorities when necessary."},
          {"id":5,"title":"Disclaimer","content":"We are not responsible for the content users post, but we commit to responding promptly to any documented legal report regarding intellectual property infringement."}
        ]
        """#
        }
        
        // MARK: - Data Deletion Request localized mock sections
        
        private var dataDeletionSectionsArabic: String {
        #"""
        [
          {"id":1,"title":"","content":"يمكنك طلب حذف بياناتك الشخصية وفقاً للقوانين المعمول بها وإجراءات التحقق الخاصة بنا."},
          {"id":2,"title":"كيفية تقديم الطلب","content":"• استخدم قسم الدعم أو المساعدة داخل التطبيق، أو\n• تواصل معنا عبر البريد الإلكتروني الرسمي للدعم الموضح داخل التطبيق."},
          {"id":3,"title":"","content":"قد نطلب منك التحقق من هويتك قبل معالجة طلب الحذف. وقد يتم الاحتفاظ ببعض المعلومات في الحالات التي يشترطها القانون (مثل السجلات الأمنية أو المحاسبية)."},
          {"id":4,"title":"وقت المعالجة","content":"سنرد عليك خلال فترة زمنية معقولة ونحيطك علماً بالنتيجة أو بأي قيود."}
        ]
        """#
        }
        
        private var dataDeletionSectionsEnglish: String {
        #"""
        [
          {"id":1,"title":"","content":"You may request deletion of your personal data subject to applicable law and our verification process."},
          {"id":2,"title":"How to request","content":"• Use the in-app Support or Help section, or\n• Contact us through the official support email shown in the app."},
          {"id":3,"title":"","content":"We may ask you to verify your identity before processing a deletion request. Some information may be retained where the law requires (for example, security or accounting records)."},
          {"id":4,"title":"Processing time","content":"We will respond within a reasonable period and inform you of the outcome or any limitations."}
        ]
        """#
        }
        
        // MARK: - Mock helpers
        
        private func mockEmpty() -> Result<BaseResponse<EmptyResponse>, APIError> {
            .success(BaseResponse(status: true, message: "OK", data: EmptyResponse()))
        }
        
        private func decodeMock<T: Decodable>(_ json: String) -> Result<BaseResponse<T>, APIError> {
            guard let data = json.data(using: .utf8) else { return .failure(APIError(type: .parsing, message: "Invalid mock JSON")) }
            do { return .success(try JSONDecoder().decode(BaseResponse<T>.self, from: data)) } catch { return .failure(APIError(type: .parsing, message: "\(error)")) }
        }
        
        private func decodeMockRaw<T: Decodable>(_ json: String) -> Result<T, APIError> {
            guard let data = json.data(using: .utf8) else { return .failure(APIError(type: .parsing, message: "Invalid mock JSON")) }
            do { return .success(try JSONDecoder().decode(T.self, from: data)) } catch { return .failure(APIError(type: .parsing, message: "\(error)")) }
        }
        
    }

