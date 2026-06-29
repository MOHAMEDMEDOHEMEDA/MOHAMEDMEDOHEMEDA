//
//  ActivityView.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = ActivityViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ActivityHeader { router.back() }

            ScrollView {
                content
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .adaptiveContentWidth()
            }
            .scrollIndicators(.hidden)
        }
        .appBackground()
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .onAppear { viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.items.isEmpty {
            ProgressView().tint(.appText).frame(maxWidth: .infinity).padding(.vertical, 40)
        } else if viewModel.items.isEmpty {
            Text("no_notifications_yet".localized)
                .font(.footnote)
                .foregroundStyle(.appText.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        } else {
            ActivityGroupedFeed(items: viewModel.items) { item in
                if item.kind == .follow {
                    ActivityFollowRow(item: item) { viewModel.followBack(item) }
                } else {
                    ActivityFeedRow(item: item)
                }
            }
        }
    }
}
