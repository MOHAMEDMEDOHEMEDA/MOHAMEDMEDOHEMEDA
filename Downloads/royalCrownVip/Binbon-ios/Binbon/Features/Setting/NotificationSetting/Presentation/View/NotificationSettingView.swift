//
//  NotificationSettingView.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotificationSettingView: View {

    @StateObject var viewModel = NotificationSettingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
            Section("new_followers_notification".localized) { followersSection }
            Section("likes_comments_notification".localized) { likesCommentsSection }
            Section("private_messages_notification".localized) { messagesSection }
            Section("direct_videos_notification".localized) { liveVideosSection }
            Section("new_stories_notification".localized) { storiesSection }
            Section("gifts_competitions_notification".localized) { giftsCompetitionsSection }
            Section("enable_disable_all_notifications".localized) { allNotificationsSection }
            Section("notification_ringtone_vibration".localized) { ringtoneVibrationSection }
            }
            .adaptiveContentWidth()

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .adaptiveContentWidth()
        }
        .appBackground()
        .appNavigation(title: "notification_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task {
            viewModel.fetchAll()
            viewModel.fetchSettings()
            viewModel.fetchSoundOptions()
        }
    }

    private var saveButton: some View {
        Button { viewModel.saveSettings() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.settingsUnchanged())
    }

    // MARK: - Loading / empty state wrapper for a feed category
    @ViewBuilder
    private func feed<Content: View>(
        _ category: NotificationCategory,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if viewModel.isLoading(category) && viewModel.items(for: category).isEmpty {
            HStack {
                Spacer()
                ProgressView().tint(.appText)
                Spacer()
            }
            .padding(.vertical, 20)
        } else if viewModel.items(for: category).isEmpty {
            Text("no_notifications_yet".localized)
                .font(.footnote)
                .foregroundStyle(.appText.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        } else {
            content()
        }
    }

    // MARK: - 1. New followers
    private var followersSection: some View {
        feed(.followers) {
            NotifGroupedFeed(items: viewModel.items(for: .followers), showDividers: false) { item in
                NotifFollowerRow(item: item) {
                    viewModel.followBack(item)
                } onUnfollow: {
                    viewModel.unfollow(item)
                }
            }
        }
    }

    // MARK: - 2. Likes & comments
    private var likesCommentsSection: some View {
        feed(.commentsLikes) {
            NotifGroupedFeed(
                items: viewModel.items(for: .commentsLikes),
                headerAccessory: { $0 == .previously ? AnyView(NotifAllFilter()) : nil },
                showDividers: false
            ) { item in
                NotifFeedRow(item: item) {
                    NotifLikeCommentBadge(isLike: item.isLikeAction)
                }
            }
        }
    }

    // MARK: - 3. Private messages
    private var messagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            NotifMessagesHeader(
                isAllSelected: viewModel.isAllMessagesSelected,
                onToggleSelectAll: viewModel.toggleSelectAllMessages,
                onMarkAllRead: { viewModel.markAllRead(in: .privateMessages) }
            )

            feed(.privateMessages) {
                ForEach(viewModel.items(for: .privateMessages)) { message in
                    NotifMessageRow(item: message) {
                        viewModel.markRead(message, in: .privateMessages)
                    }
                }
            }
        }
    }

    // MARK: - 4. Direct / live videos
    private var liveVideosSection: some View {
        feed(.liveStreams) {
            NotifGroupedFeed(items: viewModel.items(for: .liveStreams)) { item in
                NotifFeedRow(item: item) { NotifBadge(text: "notif_live".localized, color: .red) }
            }
        }
    }

    // MARK: - 5. New stories
    private var storiesSection: some View {
        feed(.newStories) {
            NotifGroupedFeed(items: viewModel.items(for: .newStories)) { item in
                NotifFeedRow(item: item) {
                    NotifCircleIcon(name: "notif-story", background: Color(hex: "E14554"))
                }
            }
        }
    }

    // MARK: - 6. Gifts & competitions
    private var giftsCompetitionsSection: some View {
        feed(.competitionsGifts) {
            NotifGroupedFeed(items: viewModel.items(for: .competitionsGifts), showDividers: false) { item in
                let isWin = item.isWinAction
                NotifFeedRow(item: item) {
                    NotifIcon(name: isWin ? "notif-cup" : "notif-gift",
                              color: isWin ? .white : Color.appGold)
                }
                .notifCardBackground()
            }
        }
    }

    // MARK: - 7. Enable / disable all
    private var allNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            NotifToggleRow(title: "all_notifications".localized, isOn: $viewModel.allNotificationsEnabled)
                .notifCardBackground()
            NotifToggleRow(title: "show_in_notification_center".localized, isOn: $viewModel.showInNotificationCenter)
                .notifCardBackground()
            NotifToggleRow(title: "music".localized, isOn: $viewModel.musicEnabled)
                .notifCardBackground()
            NotifToggleRow(title: "show_on_lock_screen".localized, isOn: $viewModel.showOnLockScreen)
                .notifCardBackground()
        }
    }

    // MARK: - 8. Ringtone & vibration
    private var ringtoneVibrationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            NotifToggleRow(title: "vibrate_while_ringing".localized, isOn: $viewModel.vibrateWhileRinging)
                .notifCardBackground()

            VStack(spacing: 0) {
                NotifSoundRow(
                    title: "ringtone".localized,
                    value: viewModel.ringtone,
                    options: viewModel.ringtoneOptions
                ) { viewModel.ringtone = $0 }

                NotifDivider()

                NotifSoundRow(
                    title: "notification".localized,
                    value: viewModel.notificationSound,
                    options: viewModel.notificationOptions
                ) { viewModel.notificationSound = $0 }

                NotifDivider()

                NotifSoundRow(
                    title: "system_sound".localized,
                    value: viewModel.systemSound,
                    options: viewModel.systemOptions
                ) { viewModel.systemSound = $0 }
            }
            .notifCardBackground()
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingView()
    }
}
