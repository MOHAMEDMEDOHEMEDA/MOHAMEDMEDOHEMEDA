//
//  StoriesSettingsView.swift
//  Binbon
//
//  Created by Husayn on 04/06/2026.
//

import SwiftUI

struct StoriesSettingsView: View {

    @StateObject var viewModel = StoriesSettingsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
            Section("who_can_view_stories".localized) { canSeeStorySection }
            Section("who_can_respond_to_the_stories".localized) { canRespondToStorySection }
            Section("save_stories_automatically".localized) { saveStoryAutomaticallySection }
            Section("sharing_stories_on_other_accounts".localized) { sharingStoriesSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "stories_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchStorySettings() }
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
    private var canSeeStorySection: some View {
        DynamicSelector(selection: $viewModel.storyVisibilityCase)
    }

    private var canRespondToStorySection: some View {
        DynamicSelector(selection: $viewModel.storyReplyCase)
    }

    private var saveStoryAutomaticallySection: some View {
        DynamicSelector(selection: $viewModel.autoSaveStoriesCase)
    }

    private var sharingStoriesSection: some View {
        DynamicSelector(selection: $viewModel.shareToOtherAccountsCase)
    }
}

#Preview {
    StoriesSettingsView()
}
