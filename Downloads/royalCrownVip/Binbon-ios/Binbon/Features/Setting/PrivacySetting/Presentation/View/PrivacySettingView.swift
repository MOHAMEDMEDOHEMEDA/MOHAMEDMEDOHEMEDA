//
//  PrivacySettingView.swift
//  Binbon
//
//  Created by Salah Khaled on 22/05/2026.
//

import SwiftUI

struct PrivacySettingView: View {
    
    @StateObject var viewModel = PrivacySettingViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
            Section("profile_visibility".localized) { profileVisibilitySection }
            Section("friend_and_follow_requests".localized) { friendFollowRequestsSection }
            Section("private_messages".localized) { privateMessagesSection }
            Section("comments_on_my_posts".localized) { commentsSection }
            Section("mention_me_in_posts".localized) { mentionsSection }
            Section("stories_visibility".localized) { storiesVisibilitySection }
            Section("share_or_download_my_posts".localized) { shareDownloadSection }
            Section("active_status".localized) { activeStatusSection }
            Section("enable_incognito_mode".localized) { incognitoModeSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "privacy_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchPrivacySettings() }
    }
    
    private var saveButton: some View {
        Button { viewModel.save() } label: {
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

    // MARK: - Sections
    private var profileVisibilitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text("who_can_see_personal_information".localized)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                
                Text("last_seen_and_online_now".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.7))
                
                DynamicSelector(selection: $viewModel.onlineCase)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("who_can_know_when_connected".localized)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                
                DynamicSelector(selection: $viewModel.profileCase)
                
                Text("last_seen_sharing_reciprocal".localized)
                    .font(.caption)
                    .foregroundStyle(.appText.opacity(0.7))
            }
        }
    }
    
    private var friendFollowRequestsSection: some View {
        DynamicSelector(selection: $viewModel.friendCase)
    }
    
    private var privateMessagesSection: some View {
        DynamicSelector(selection: $viewModel.privateMessageCase)
    }
    
    private var commentsSection: some View {
        DynamicSelector(selection: $viewModel.commentCase)
    }
    
    private var mentionsSection: some View {
        DynamicSelector(selection: $viewModel.mentionCase)
    }
    
    private var storiesVisibilitySection: some View {
        DynamicSelector(selection: $viewModel.storyCase)
    }
    
    private var shareDownloadSection: some View {
        DynamicSelector(selection: $viewModel.shareCase)
    }
    
    private var activeStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("who_can_see_activity_status".localized)
                .font(.footnote)
                .foregroundStyle(.appText.opacity(0.7))
            
            DynamicSelector(selection: $viewModel.activeCase)
        }
    }
    
    private var incognitoModeSection: some View {
        Toggle(isOn: $viewModel.incognitoCase) {
            HStack {
                Image("incognito-mode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("incognito_mode".localized)
                    .foregroundStyle(.appText)
                    .font(.footnote.weight(.medium))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        PrivacySettingView()
    }
}
