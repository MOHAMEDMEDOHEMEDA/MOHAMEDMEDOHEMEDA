//
//  CreatorsSettingView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 08/06/2026.
//

import SwiftUI

struct CreatorsSettingView: View {

    @Environment(\.router) private var router

    var body: some View {
        VStack(spacing: 0) {
            ExpandView {
                Section("creator_virtual_currency_gifts".localized, padding: false) {
                    CreatorVirtualCurrencyView()
                }
                Section("creator_views_ads_earnings".localized) {
                    router.navigate(.creatorViewsEarnings)
                }
                Section("creator_enable_gifts".localized) {
                    CreatorEnableGiftsView()
                }
                Section("creator_payment_accounts_link".localized) {
                    CreatorLinkPaymentView()
                }
                Section("creator_detailed_stats".localized) {
                    router.navigate(.creatorStatistics)
                }
                Section("creator_live_settings".localized) {
                    CreatorLiveStreamView()
                }
                Section("creator_vip_mode".localized) {
                    CreatorVIPView()
                }
                Section("creator_subscription_content".localized) {
                    CreatorSubscriptionView()
                }
            }

            AppButton(title: "save_changes".localized) {
                // TODO: wire up save action once sections have view models
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "creators_settings".localized)
    }
}

#Preview {
    NavigationView {
        CreatorsSettingView()
    }
}
