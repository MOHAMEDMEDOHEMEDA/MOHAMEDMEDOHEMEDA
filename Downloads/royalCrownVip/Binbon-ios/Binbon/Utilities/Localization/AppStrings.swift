//
//  AppStrings.swift
//  Binbon
//
//  Typed localization keys. Each constant is a key into en.json / ar.json,
//  resolved at the call site with `.localized` / `.localizedFormat(_:)`.
//  Grouped by screen; add a new MARK section when a feature adopts it.
//

import Foundation

enum AppStrings {

    // MARK: - Security Settings
    static let twoFactorAuthentication = "two_factor_authentication"
    static let latestActivities = "latest_activities"
    static let signInLogs = "sign_in_logs"
    static let biometricManagement = "biometric_management"
    static let changePassword = "change_password"
    static let newDeviceSecurityAlerts = "new_device_security_alerts"
    static let privacySettings = "privacy_settings"
    static let disableTwoFactorAuthentication = "disable_two_factor_authentication"
    static let enterYourPassword = "enter_your_password"
    static let cancel = "cancel"
    static let disable = "disable"
    static let enterPasswordToDisable2FA = "enter_password_to_disable_2fa"
    static let alright = "alright"
    static let save = "save"
    static let twoFADescription = "two_fa_description"
    static let enable = "enable"
    static let noRecentActivity = "no_recent_activity"
    static let activityLog = "activity_log"
    static let noActivityInPeriod = "no_activity_in_period"
    static let retry = "retry"
    static let noLoginHistory = "no_login_history"
    static let loginHistory = "login_history"
    static let noLoginInPeriod = "no_login_in_period"
    static let biometricLoginDescription = "biometric_login_description"
    static let biometricUnavailableMessage = "biometric_unavailable_message"
    static let biometricNoHardware = "biometric_no_hardware"
    static let currentPassword = "current_password"
    static let enterCurrentPassword = "enter_current_password"
    static let newPassword = "new_password"
    static let enterNewPassword = "enter_new_password"
    static let confirmPassword = "confirm_password"
    static let enterConfirmPassword = "enter_confirm_password"
    static let passwordRequirements = "password_requirements"
    static let updatePassword = "update_password"
    static let securityAlertTitle = "security_alert_title"
    static let securityAlertDescription = "security_alert_description"
    static let thisWasMe = "this_was_me"
    static let thisWasntMe = "this_wasnt_me"
    static let newDeviceAlertsDescription = "new_device_alerts_description"
    static let showMore = "show_more"

    // MARK: - Comments
    static let commentsCount = "comments_count"
    static let reply = "reply"
    static let close = "close"

    // MARK: - Confirm popup
    static let open = "open"
    /// Title for the "leave Bin Bon to open <app>" confirmation. Takes the
    /// destination app name as its single `%@` argument.
    static let confirmOpenApp = "confirm_open_app"

    // MARK: - Live Countries
    /// Continent section headers in the broadcasts-by-country picker.
    static let liveCountrySectionArabWorld = "live_country_section_arab_world"
    static let liveCountrySectionEurope    = "live_country_section_europe"
    static let liveCountrySectionAsia      = "live_country_section_asia"
    static let liveCountrySectionAmericas  = "live_country_section_americas"
    static let liveCountrySectionAfrica    = "live_country_section_africa"
    static let liveCountrySectionOceania   = "live_country_section_oceania"

    /// Small caption shown above the country name on the country detail hero.
    static let liveCountryServer = "live_country_server"

    // MARK: - Stories (My Stories screen)
    /// Stats row labels on the profile header.
    static let storyStatLikes      = "story_stat_likes"
    static let storyStatFollowers  = "story_stat_followers"
    static let storyStatFollowing  = "story_stat_following"
    /// Identifier line under the user's name. Single `%@` arg = the user id.
    static let storyBinbonIdFormat = "story_binbon_id_format"
    /// Caption under the small cover thumbnail on the right of the header.
    static let storyCoverOfficial  = "story_cover_official"
    /// Tiny "برج" caption next to the zodiac glyph.
    static let storyZodiacLibra    = "story_zodiac_libra"
    /// Three action chips below the stats row.
    static let storyActionEdit     = "story_action_edit"
    static let storyActionShare    = "story_action_share"
    static let storyActionFind     = "story_action_find"
    /// Horizontally scrolling quick-filter pills.
    static let storyPillClips      = "story_pill_clips"
    static let storyPillVideo      = "story_pill_video"
    static let storyPillPhoto      = "story_pill_photo"
    static let storyPillStory      = "story_pill_story"
    static let storyPillSave       = "story_pill_save"
    static let storyPillLive       = "story_pill_live"
    /// Stories tab bar — six tabs, selected one is "my".
    static let storyTabMy          = "story_tab_my"
    static let storyTabTrending    = "story_tab_trending"
    static let storyTabFriends     = "story_tab_friends"
    static let storyTabFollowing   = "story_tab_following"
    static let storyTabFollowers   = "story_tab_followers"
    static let storyTabSaved       = "story_tab_saved"
    /// Caption under the big empty-state avatar card.
    static let storyMyToday        = "story_my_today"
    /// Save-my-story day tabs and panel captions.
    static let saveMyStoryDayToday     = "save_my_story_day_today"
    static let saveMyStoryDayYesterday = "save_my_story_day_yesterday"
    static let saveMyStoryDayBefore    = "save_my_story_day_before"
    static let saveMyStoryCaptionToday     = "save_my_story_caption_today"
    static let saveMyStoryCaptionYesterday = "save_my_story_caption_yesterday"
    static let saveMyStoryCaptionBefore    = "save_my_story_caption_before"
    static let saveMyStoryDelete           = "save_my_story_delete"
    static let saveMyStoryDeletedLabel     = "save_my_story_deleted_label"
    /// Localization key for a country's display name, by ISO code
    /// (e.g. `live_country_eg`). Values live in en.json / ar.json.
    static func liveCountryName(_ code: String) -> String { "live_country_\(code)" }
}
