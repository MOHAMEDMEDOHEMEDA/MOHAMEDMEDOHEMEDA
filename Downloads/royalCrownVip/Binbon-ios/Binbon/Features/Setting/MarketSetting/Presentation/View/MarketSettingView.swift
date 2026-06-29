//
//  MarketSettingView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI

struct MarketSettingView: View {
    
    @Environment(\.router) var router
    @StateObject var viewModel = MarketSettingViewModel()
    
    var body: some View {
        ExpandView {
            Section("add_products_to_account".localized) { mallSection }
            Section("account_and_privacy_settings".localized) { accountPrivacySection }
        }
        .adaptiveContentWidth()
        .appBackground()
        .navigationTitle("shopping_settings".localized)
    }
    
    // MARK: - The Mall
    private var mallSection: some View {
        Button {
            // TODO: navigate to mall
        } label: {
            VStack(alignment: .leading) {
                Text("shopping_settings".localized)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .padding(.top, 10)
                
                HStack(spacing: 14) {
                    Image("mall")
                        .resizable()
                        .frame(width: 32, height: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("the_mall".localized)
                            .font(.system(size: 20, weight: .bold, design: .default))
                        
                        Text("mall_subtitle".localized)
                            .font(.caption)
                            .foregroundStyle(AppColor.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppColor.secondaryTextColor)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Account & Privacy
    private var accountPrivacySection: some View {
        VStack(spacing: 20) {
            toggleRow("convert_to_private_account".localized,
                      isOn: $viewModel.isPrivateAccount)
            
            toggleRow("convert_to_public_account".localized,
                      isOn: $viewModel.isPublicAccount)
            
            toggleRow("accept_friend_requests_when_private".localized,
                      isOn: $viewModel.acceptFriendRequestsWhenPrivate)
        }
        .padding(.top, 4)
    }
    
    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .default))
                .lineLimit(nil)
        }
        .tint(.green)
    }
}
