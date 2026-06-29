//
//  InteractionSettingView.swift
//  Binbon
//
//  Created by Aya Mashaly on 03/06/2026.
//

import SwiftUI

struct InteractionSettingView: View {
    
    @Environment(\.router) var router
    @StateObject var viewModel = InteractionSettingViewModel()
    @StateObject private var blockedUsersviewModel = BlockedUsersViewModel()
    @StateObject private var liveVM = LiveStreamSettingsViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
                Section("allow_or_disable_comments".localized) { commentsSection }
                Section("control_likes_and_viewers".localized) { likesAndViewersSection }
                Section("manage_block_list".localized) { blockListSection }
                Section("allow_voice_photos_videos".localized) { mediaMessagesSection }
                Section("manage_account_earnings".localized) { earningsSection }
                Section("gifts_settings".localized) { giftsSection }
                Section("payment_methods_title".localized) { paymentMethodsSection }
                Section("live_stream_settings".localized) { liveStreamSection }
                Section("buy_vip_levels".localized) { vipSection }
                Section("subscription_content_control".localized) { subscriptionContentSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .navigationTitle("interaction_settings".localized)
//        .toolbar { toolbar }
        .addPaymentCardAlert(isPresented: $viewModel.showAddPaymentAlert) { card in
            viewModel.paymentCards.append(card)
        }
        .task {
            viewModel.fetchInteractionSettings()
            blockedUsersviewModel.fetchBlockedUsers(reset: true)
            liveVM.fetchLiveStreamSettings()
        }
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await liveVM.updateLiveStreamSettings()
                viewModel.save()
            }
        } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDataNoChanges())
    }
    
    // MARK: - Comments
    private var commentsSection: some View {
        Toggle(isOn: $viewModel.allowComments) {
            Text("allow_or_disable_comments".localized)
                .font(.footnote.weight(.semibold))
                .lineLimit(nil)
        }
        .tint(.green)
    }
    
    // MARK: - Likes & Viewers
    private var likesAndViewersSection: some View {
        Toggle(isOn: $viewModel.allowMediaMessages) {
            Text("control_likes_show_hide".localized)
                .font(.footnote.weight(.semibold))
                .lineLimit(nil)
        }
        .tint(.green)
    }
    
    // MARK: - Block List
    private var blockListSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("block_list".localized)
                        .font(.footnote.weight(.semibold))
                    
                    ForEach(blockedUsersviewModel.blockedUsers) { user in
                        HStack {
                            Text("@\(user.username)")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Button("unblock".localized) {
                                blockedUsersviewModel.unblockUser(user)
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(hex: "#F5A623"))
                        }
                        .onAppear {
                            blockedUsersviewModel.loadMoreIfNeeded(currentUser: user)
                        }
                    }
                    
                    if blockedUsersviewModel.isLoadingBlocked {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                
                
                VStack(spacing: 10) {
                    Text("add_account_to_block_list".localized)
                        .font(.footnote.weight(.semibold))
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 0) {
                        Button("block".localized) {
                            blockedUsersviewModel.blockUser()
                        }
                        .font(.footnote.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .disabled(blockedUsersviewModel.blockUsername.trimmingCharacters(in: .whitespaces).isEmpty)
                        
                        TextField("", text: $blockedUsersviewModel.blockUsername)
                            .font(.footnote)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .environment(\.layoutDirection, .rightToLeft)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 6)
                        
                        Text("@")
                            .font(.footnote)
                            .foregroundStyle(AppColor.secondaryTextColor)
                            .padding(.horizontal, 14)
                    }
                    .overlay(
                        Capsule().stroke(AppColor.secondaryTextColor, lineWidth: 1.5)
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Media Messages
    private var mediaMessagesSection: some View {
        DynamicSelector(selection: $viewModel.mediaMessagesPermission)
    }
    
    private var earningsSection: some View {
        LazyVStack(spacing: 0) {
            ForEach(earningsItems, id: \.self) { item in
                Button {
                    print(item)
                    
                    if let route = route(for: item) {
                        router.navigate(route)
                    }
                } label: {
                    HStack {
                        Text(item.localized)
                            .font(.footnote.weight(.semibold))
                        
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppColor.secondaryTextColor)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if item != earningsItems.last {
                    Divider()
                }
            }
        }
    }
    
    private func route(for item: String) -> Route? {
        switch item {
        case "earnings_video_views":
            return .earningsVideoViews
        default:
            return nil
        }
    }
    
    // MARK: - Gifts Section
    private var giftsSection: some View {
        Toggle(isOn: $liveVM.giftsEnabled) {
            Text("gifts_toggle_title".localized)
                .font(.footnote.weight(.semibold))
                .lineLimit(nil)
        }
        .tint(.green)
    }
    
    // MARK: - Payment Methods
    private var paymentMethodsSection: some View {
        PaymentMethodsList(
            cards: viewModel.paymentCards,
            wallets: viewModel.paymentWallets,
            onAdd: { viewModel.showAddPaymentAlert = true },
            onDelete: viewModel.deleteCard,
            onPay: viewModel.pay(with:)
        )
    }
    
    // MARK: - Live Stream
    private var liveStreamSection: some View {
        LiveStreamControlsList(viewModel: liveVM)
    }

    // MARK: - VIP
    private var vipSection: some View {
        VIPControlsList(onMembershipLevelTap: {
            // TODO: navigate
        })
    }

    // MARK: - Subscription Content
    private var subscriptionContentSection: some View {
        SubscriptionContentList(subscriptions: [
            SubscriptionItem(clubName: "نادي Shady Nabil",          price: "5.89 $ / شهر"),
            SubscriptionItem(clubName: "نادي Salma Nabil",          price: "5.89 $ / شهر"),
            SubscriptionItem(clubName: "معجب مميز بنادي Saif gamer", price: "9.89 $ / شهر")
        ])
    }
    
    // MARK: - Earnings
    
    private let earningsItems = [
        "earnings_video_views",
        "earnings_story_views",
        "earnings_reels_views",
        "earnings_short_video_views",
        "earnings_live_views",
        "manage_account_earnings"
    ]
}
