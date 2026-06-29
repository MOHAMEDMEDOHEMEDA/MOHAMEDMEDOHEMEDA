//
//  AdsSettingView.swift
//  Binbon
//
//  Created by Mahmoud Elsharkawy on 18/06/2026.
//

import SwiftUI

struct AdsSettingView: View {

    @StateObject var viewModel = AdsSettingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
                Section("sponsored_ad_long_video".localized) { Color.clear.frame(height: 120) }
                Section("sponsored_ad_short_video".localized) { Color.clear.frame(height: 120) }
                Section("sponsored_ad_product".localized) { Color.clear.frame(height: 120) }
                Section("sponsored_ad_story".localized) { Color.clear.frame(height: 120) }
                Section("sponsored_ad_live_streaming".localized) { Color.clear.frame(height: 120) }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "advertisements".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchAdsSettings() }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button { viewModel.save() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.buttonGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDataNoChanges())
    }
}

#Preview {
    AdsSettingView()
}
