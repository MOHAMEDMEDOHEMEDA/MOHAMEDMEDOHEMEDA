# Localization Audit — Binbon iOS

**Date:** 2026-06-02
**Approach:** JSON-based localization (no Xcode String Catalogs)
**Languages:** English (`en`) · Arabic (`ar`)

---

## 1. System Overview

| Component | Location | Notes |
|---|---|---|
| Translation tables | `Binbon/Localization/en.json`, `Binbon/Localization/ar.json` | 291 keys each, identical key sets |
| `LocalizationManager` | `Binbon/Utilities/Localization/Localizer.swift` | Loads JSON from bundle, reads current language from `Storage`, falls back to English → raw key |
| `String.localized` | `Binbon/Utilities/Localization/Localizer.swift` | `"login".localized` → resolved value |
| `String.localizedFormat(_:)` | `Binbon/Utilities/Localization/Localizer.swift` | For placeholders (`%@`, `%d`, `%f`) |

No new screen/view files were created and no architecture, APIs, models, networking, or assets were changed. The two JSON files live under the existing `Binbon/` file-system–synchronized group, so they are bundled automatically (no `.pbxproj` change needed). `LocalizationManager` and the `localized` extension were added **into the existing** `Localizer.swift` rather than a new file.

Usage:
```swift
Text("login".localized)                                   // SwiftUI
label.text = "login".localized                            // UIKit
AppButton(title: "create_account".localized) { … }        // custom widget
Text("code_sent_to_email".localizedFormat(email))         // %@ placeholder
```

---

## 2. Totals

| Metric | Value |
|---|---|
| Total localization keys (en) | **291** |
| Total localization keys (ar) | **291** |
| Key-set parity (en ↔ ar) | ✅ identical, 0 missing |
| Placeholder parity (`%@`/`%d`/`%f`) | ✅ 0 mismatches |
| Duplicate keys | ✅ none |
| `.localized` / `.localizedFormat` call sites | **374** |
| Source files modified | **47** |
| Swift files (all) passing `swiftc -parse` | **121 / 121** |
| Unresolved `"key".localized` references (key missing from JSON) | **0** |
| Remaining `String(localized:)` (String Catalog) usages | **0** (migrated) |

**Overall localization coverage of in-scope user-facing strings: ~97%.**
The remaining ~3% are intentionally excluded categories (mock/sample data, enum `rawValue`s sent to the backend, validation field-name arguments, and `#Preview`-only literals) — see §6.

---

## 3. Coverage by Feature / Module

| Feature | Localized call-sites | Remaining (in-scope) | Coverage | Status |
|---|---|---|---|---|
| **Auth** (login, register, OTP, profile setup) | 40 | 0 | 100% | ✅ Fully localized |
| **ForgetPassword** (forget / verify OTP / reset) | 23 | 0 | 100% | ✅ Fully localized |
| **Settings** (account, privacy, security, 2FA) | 107 | 0 | 100% | ✅ Fully localized |
| **Follow** (followers/following/likes) | 25 | 0 | 100% | ✅ Fully localized |
| **Onboard** | 13 | 0 | 100% | ✅ Fully localized |
| **Home** | 1 | 0 | 100% | ✅ Fully localized |
| **Splash** | 1 | 0 | 100% | ✅ Fully localized |
| **Shared Widgets** (tab bar, fields, alerts, pickers, image picker) | 25 | 0 | 100% | ✅ Fully localized (previews excluded) |
| **App** (router / session-expired alert) | 3 | 0 | 100% | ✅ Fully localized |
| **Validation** (`FormValidation`) | 28 | 0 | 100% | ✅ Fully localized |
| **Profile** (profile, edit, find friends, share, settings) | 74 | ~6 | ~93% | 🟡 Partially localized |
| **Reel** | 3 | 1 | ~75%* | 🟡 Partially (only dummy text remains) |
| **Verification** (KYC steps) | 41 | ~8 | ~84% | 🟡 Partially localized |

\* Reel’s only remaining string is hardcoded placeholder content (`#Lorem #Lorem #Lorem`); all real UI strings are localized.

> There is no dedicated **Chat / Messages**, **Notifications**, or **Search** feature module in the current codebase. "Messages" and "Create" exist only as tab-bar labels (localized: `messages`, `create`) backed by placeholder `DummyView`s. The Find-Friends search bar and empty state are localized under **Profile** (`search`, `no_search_results`).

### Status summary
- **Fully localized (100%):** Auth, ForgetPassword, Settings, Follow, Onboard, Home, Splash, Shared Widgets, App, Validation
- **Partially localized:** Profile (~93%), Verification (~84%), Reel (~75%, remainder is dummy text)
- **Not localized:** none (every feature has its real user-facing strings localized)

---

## 4. Key Groups (sample)

| Group | Example keys |
|---|---|
| Auth | `login`, `create_account`, `account_login`, `forgot_password`, `enter_account_information`, `code_sent_to_email` |
| ForgetPassword | `forget_password`, `verify_otp`, `reset_password`, `enter_otp_code`, `password_reset_successfully` |
| Verification | `account_verification`, `full_name`, `id_number`, `front_side`, `back_side`, `tap_to_open_camera`, `verification_submitted_72h` |
| Profile | `profile`, `edit_profile`, `share_profile`, `find_friends`, `binbon_id`, `logout_confirmation`, `no_search_results` |
| Settings | `account_setting`, `privacy_settings`, `security_settings`, `two_factor_authentication`, `password_requirements`, `sign_out_from_device` |
| Follow | `no_followers_yet`, `not_following_anyone`, `follow`, `unfollow`, `unlike`, `remove_follower_confirmation` |
| Onboard | `singers_actors`, `famous_people`, `follow_count`, `skip` |
| Shared / System | `cancel`, `confirm`, `save`, `done`, `retry`, `error`, `session_expired`, `error_processing_request` |
| Validation | `validation_enter_email`, `validation_invalid_email`, `validation_password_min`, `validation_min_age` |

---

## 5. Modified Files (47)

**Localization core**
- `Binbon/Utilities/Localization/Localizer.swift` (added `LocalizationManager` + `String.localized` / `localizedFormat`)
- `Binbon/Utilities/Validation/FormValidation.swift`

**New (data only)**
- `Binbon/Localization/en.json`
- `Binbon/Localization/ar.json`

**Auth** — `LoginView`, `AuthSelectionView`, `CreateAccountView`, `EmailVerificationView`, `ProfileSetupView`, `AccountVerifiedView`
**ForgetPassword** — `ForgetPassView`, `ForgetPassViewModel`, `VerifyOTPView`, `VerifyOTPViewModel`, `ResetPassView`, `ResetPassViewModel`
**Verification** — `VerificationView`, `VerificationSuccessView`, `VerificationViewModel`, `Step1PersonalInfoView`, `Step2DocumentView`, `Step3SelfieView`
**Profile** — `ProfileView`, `EditProfileView`, `EditProfileViewModel`, `FindFriendsView`, `ShareProfileView`, `ProfileSettingView`
**Settings** — `AccountSettingView`, `AccountSettingViewModel`, `PrivacySettingView`, `PrivacySettingViewModel`, `SecuritySettingView`, `TwoFactorView`
**Home / Reel / Follow / Onboard / Splash** — `HomeView`, `ReelsView`, `FollowView`, `FollowTab`, `FollowViewModel`, `OnboardView`, `OnboardViewModel`, `SplashView`
**Widgets** — `AppTabBar`, `DatePickerSheet`, `ErrorAlertModifier`, `PhoneFieldWithDropdown`, `ProfileImageView`
**App** — `AppRouter`
**Network** — `Network/Extensions/Extensions.swift` (migrated two `String(localized:)` copy strings to `.localized`)

---

## 6. Remaining Hardcoded Strings (intentionally excluded)

These were left in place on purpose, with rationale:

| File / Location | String(s) | Reason |
|---|---|---|
| `Screens/Reel/View/ReelsView.swift` | `#Lorem #Lorem #Lorem` | Placeholder/dummy content, not real copy |
| `Screens/Profile/ProfileSetting/ProfileSettingView.swift` | `Gold ID: أبن سوريا` | Hardcoded sample/mock data |
| `Screens/Profile/Profile/Model/MediaModel.swift` | Sample tab titles (`Media`, `Private`, `Saved`, `Liked`) + category names | Mock sample data inside a **model** file (rule: do not change models); will be replaced by API data |
| `Screens/Verification/ViewModel/VerificationViewModel.swift` | `Address`, `City`, `Village`, `WhatsApp`, `State` (passed as `FormValidation.check(title:)`) | Field-name arguments interpolated into already-localized validation templates; localizing them needs grammar-aware keys |
| `Screens/Profile/EditProfile/ViewModel/EditProfileViewModel.swift` | `Gender` (validation `title:`) | Same as above |
| Verification `documentType` enum `rawValue`s | `National ID`, `Passport`, `Driver's License` | Enum raw values used in API payloads — changing them would alter backend data |
| `Extensions/String.swift` (`zodiac()`) | Zodiac sign names + `Select Date` fallback | Astrological proper names in a utility helper; out of typical UI-copy scope |
| `Widgets/AppTextField.swift`, `Widgets/AppButton.swift` | `#Preview` literals (`"Enter your password"`, `"Title"`) | SwiftUI previews — not shipped UI |
| Dynamic interpolations (`@\(username)`, like counts, `\(value)`) | — | Pure runtime values, not translatable text |

**Explicitly ignored per spec:** API endpoints, JSON keys, URLs, image/asset names, SF Symbol names, color hex values, debug/print logs, analytics/Firebase keys, database fields.

---

## 7. Verification Performed

- ✅ `en.json` and `ar.json` parse as valid JSON, **291 keys each**, identical key sets, no duplicate keys.
- ✅ Placeholder tokens (`%@`, `%d`, `%f`) match between `en` and `ar` for every key.
- ✅ Every `"key".localized` / `.localizedFormat` reference in code resolves to an existing JSON key (0 missing).
- ✅ All 121 Swift files pass `xcrun swiftc -parse` (0 syntax errors).
- ✅ All `String(localized:)` (String Catalog) usages migrated to the JSON system (0 remaining).

### How to switch language at runtime
The existing `Localizer.change(language:)` already persists the choice to `Storage.language` and re-renders the SwiftUI tree (via `.localizer()` / `.id(language)`); `LocalizationManager.text(_:)` reads that same `Storage.language` on each lookup, so `.localized` values update automatically when the language changes.
