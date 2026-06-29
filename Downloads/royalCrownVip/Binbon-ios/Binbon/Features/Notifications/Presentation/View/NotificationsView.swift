//
//  NotificationsView.swift
//  Binbon
//
//  Created by Husayn on 09/06/2026.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("new_followers".localized)
                        .font(.headline.bold())
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(viewModel.newFollowers) { follower in
                        NewFollowerRow(follower: follower) {
                            viewModel.followBack(follower)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "notifications".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .onAppear { viewModel.onAppear() }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
