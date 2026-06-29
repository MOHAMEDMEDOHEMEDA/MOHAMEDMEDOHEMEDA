//
//  Route.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI
import Combine

// MARK: - Route
enum Route: Hashable {
    case authSelection
    case login
    case createAccount
    case profileSetup(AuthViewModel)
    case accountVerified(AuthViewModel)
    case emailVerification(AuthViewModel)
    case verificationIntro
    case verification
    case verificationSuccess(status: Bool?, message: String?)
    case onboard(OnboardStepEnum)
    case home
    case editProfile
    case forgetPassword
    case verifyOTP(PasswordRequest)
    case resetPassword(PasswordRequest)
    case follow(FollowTab)
    case findFriend
    case shareProfile
    case createVideo
    case videoDetails(VideoModel)
    case photos
    case profile
    case messages
    case videoCall(contactName: String, avatarURL: String?)
    case voiceCall(contactName: String, avatarURL: String?, transitionsToVideo: Bool)
    
    case chat(MessageConversation)
//    case notifications
    case activity
    case report
    case friendReport(FriendItem)
    case friendReportDetails(friend: FriendItem, reason: FriendReportReason)
    case reportIPInfringement
    case liveBroadcastsList(LiveCategoryKind)
    case liveCountryBroadcasts(LiveCountry)
    case storyViewer(StoryViewerData)
    
    /// Settings
    case profileSetting
    case accountSetting
    case privacySetting
    case securitySetting
    case notificationSetting
    case contentPrivacySetting
    case liveStreamSetting
    case twoFactor
    case dataCacheSettings
    case storiesSettings
    case themeSetting
    case gameSetting
    case helpAndSupport
    case interactionSetting
    case languageRegionView
    case earningsVideoViews
    case marketingSetting
    case paymentAndProfitSettings
    case creatorsSettings
    case creatorViewsEarnings
    case creatorStatistics
    case promoteSettings
    case legalSettings
    case adsSetting
    case frequentlyAskedQuestions
    case faqDetail(question: String, answer: String)

    // Information Forms
    case anchorInformationForm
    case agencyInformationForm
    case hostIncome
    case goldRecharge

    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case .authSelection: AuthSelectionView()
        case .login: LoginView()
        case .createAccount: CreateAccountView()
        case .profileSetup(let viewModel): ProfileSetupView(viewModel: viewModel)
        case .accountVerified(let viewModel): AccountVerifiedView(viewModel: viewModel)
        case .emailVerification(let viewModel): EmailVerificationView(viewModel: viewModel)
        case .verificationIntro: VerificationIntroView()
        case .verification: VerificationView()
        case .verificationSuccess(let status, let message): VerificationSuccessView(status: status, message: message)
        case .onboard(let step): OnboardView(step: step)
        case .home: AppTabBarView()
        case .editProfile: EditProfileView(isPresented: .constant(false))
        case .forgetPassword: ForgetPassView()
        case .verifyOTP(let request): VerifyOTPView(request: request)
        case .resetPassword(let request): ResetPassView(request: request)
        case .follow(let tab): FollowView(initialTab: tab)
        case .findFriend: FindFriendsView()
        case .shareProfile: ShareProfileView()
        case .createVideo: CreateVideoView()
        case .videoDetails(let video): VideoDetailsView(video: video, viewModel: VideosViewModel())
        case .photos: PhotosView()
        case .profile: ProfileView()
        case .messages: MessagesView()
        case .videoCall(let contactName, let avatarURL):
            VideoCallView(contactName: contactName, avatarURL: avatarURL)
        case .voiceCall(let contactName, let avatarURL, let transitionsToVideo):
            VoiceCallsView(contactName: contactName, avatarURL: avatarURL, transitionsToVideo: transitionsToVideo)
        case .chat(let conversation): ChatView(conversation: conversation)

        case .report: ReportView()
        case .friendReport(let friend): FriendReportReasonsView(friend: friend)
        case .friendReportDetails(let friend, let reason):
            FriendReportDetailsView(friend: friend, reason: reason)
        case .reportIPInfringement: ReportIPInfringementView()
        case .liveBroadcastsList(let category): BroadcastsListView(initialCategory: category)
        case .liveCountryBroadcasts(let country): CountryBroadcastsView(country: country)
        case .storyViewer(let data): StoryViewerView(data: data)

        /// Settings
        case .profileSetting: ProfileSettingView()
        case .accountSetting: AccountSettingView()
        case .privacySetting: PrivacySettingView()
        case .securitySetting: SecuritySettingView()
        case .notificationSetting: NotificationSettingView()
        case .contentPrivacySetting: ContentPrivacySettingView()
        case .liveStreamSetting: LiveStreamSettingView()
        case .twoFactor: TwoFactorView()
        case .dataCacheSettings: DataCacheSettings()
        case .storiesSettings: StoriesSettingsView()
        case .themeSetting: ThemeSettingView()
        case .gameSetting: GameSettingView()
        case .helpAndSupport: HelpAndSupportView()
        case .interactionSetting: InteractionSettingView()
        case .earningsVideoViews: EarningsVideoViewsView()
        case .marketingSetting: MarketSettingView()
        case .paymentAndProfitSettings: PaymentAndProfitSettingsView()
        case .creatorsSettings: CreatorsSettingView()
        case .creatorViewsEarnings: CreatorViewsEarningsView()
        case .creatorStatistics: CreatorStatisticsView()
        case .promoteSettings: PromoteView()
        case .legalSettings: LegalSettingsView()
        case .adsSetting: AdsSettingView()
        case .frequentlyAskedQuestions: FrequentlyAskedQuestionsView()
        case .faqDetail(let question, let answer): FAQDetailView(question: question, answer: answer)

        /// Information Forms
        case .anchorInformationForm: AnchorInformationFormView()
        case .agencyInformationForm: AgencyInformationFormView()
        case .hostIncome: IncomeView()
        case .goldRecharge: GoldRechargeView()
//        case .notifications: NotificationsView()
        case .activity: ActivityView()
        case .languageRegionView:
            LangaugeRegionView()
        }
    }

    /// The Lottie intro overlay is suppressed across the auth / onboarding flow —
    /// those screens get the dedicated action overlay on login / create account
    /// instead.
    var showsIntroLoading: Bool {
        switch self {
        case .authSelection, .login, .createAccount, .profileSetup, .accountVerified,
             .emailVerification, .verificationIntro, .verification, .verificationSuccess,
             .forgetPassword, .verifyOTP, .resetPassword, .onboard:
            return false
        default:
            return true
        }
    }
}


// MARK: - App Router
final class AppRouter: ObservableObject {
    
    // MARK: - Properties
    static let shared = AppRouter()
    @Published var path = NavigationPath()
    @Published var route: Route = .authSelection
    @Published var showSplash = true
    
    // MARK: - Init
    init() {
         if Storage.shared.token != nil,
            Storage.shared.user?.onboardingCompleted == true,
            Storage.shared.user?.onboardingRequired == false {
             route = .home
         }
    }

    /// Dismisses the splash once its logo has appeared and held.
    func dismissSplash() {
        withAnimation(.easeOut(duration: 0.3)) {
            showSplash = false
        }
    }
    
    // MARK: - Methods
    func navigate(_ route: Route) {
        path.append(route)
    }
    
    func back() {
        if canBack() { path.removeLast() }
    }
    
    func canBack() -> Bool {
        return path.count > 0
    }
    
    func root(_ route: Route) {
        self.path = NavigationPath()
        self.route = route
    }
}

// MARK: - Environment
private struct RouterKey: EnvironmentKey {
    static let defaultValue: AppRouter = .shared
}

extension EnvironmentValues {
    var router: AppRouter {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

// MARK: - App Root
struct AppRoot: View {
    @StateObject private var router: AppRouter = .shared
    @State private var unauthorizeAlert = false
    
    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                router.route.view
                    .navigationDestination(for: Route.self) { $0.view.screenLoading(isActive: $0.showsIntroLoading) }
            }
            .environment(\.router, router)
            
            /// Unauthorize Alert
            .alert("session_expired".localized, isPresented: $unauthorizeAlert) {
                Button("sign_in".localized) {
                    Storage.shared.logout()
                    router.root(.authSelection)
                }
            } message: {
                Text("session_expired_message".localized)
            }
            .onReceive(Network.shared.unauthorize.first()) { _ in
                guard !unauthorizeAlert else { return }
                unauthorizeAlert = true
            }

            /// App-wide floating assistive button (over all in-app content)
            FloatingAssistiveButtonOverlay()

            /// Splash
            if router.showSplash {
                SplashView { router.dismissSplash() }
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
    }
}
