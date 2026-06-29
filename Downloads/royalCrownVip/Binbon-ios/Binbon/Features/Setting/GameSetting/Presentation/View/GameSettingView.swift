//
//  GameSettingView.swift
//  Binbon
//


import SwiftUI

struct GameSettingView: View {

    @StateObject private var viewModel = GameSettingViewModel()

    var body: some View {
        ExpandView {
            Section("manage_game_notifications".localized) { notificationsSection }
            Section("view_achievements_points".localized) { achievementsSection }
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "inapp_games_settings".localized)
        .task { viewModel.loadAchievements() }
    }

    // MARK: - 1. Manage game notifications
    private var notificationsSection: some View {
        NotifToggleRow(
            title: "enable_notifications".localized,
            isOn: $viewModel.gameNotificationsEnabled
        )
//        .notifCardBackground()
    }

    // MARK: - 2. Achievements & points
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            GamePeriodMenu(
                selection: $viewModel.selectedPeriod,
                dateText: viewModel.headerDateText
            )

            if viewModel.visibleAchievements.isEmpty {
                Text("no_achievements_yet".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.visibleAchievements) { achievement in
                    GameAchievementRow(achievement: achievement)
                }

                if viewModel.canLoadMore {
                    Button { viewModel.loadMore() } label: {
                        HStack(spacing: 4) {
                            Text("more".localized)
                            Image(systemName: "chevron.down")
                                .imageScale(.small)
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.appText)
                    }
                    .padding(.top, 2)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GameSettingView()
    }
}
