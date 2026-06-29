//
//  ShortsView.swift
//  Binbon
//
//  The Shorts feed: a full-bleed vertical pager of short videos. Hosted inside
//  the Home tab strip. Mock-backed during the UI-only phase.
//

import SwiftUI

struct ShortsView: View {

    @StateObject private var viewModel = ShortsViewModel()

    var body: some View {
        content
            .ignoresSafeArea(.all)
            .persistentSystemOverlays(.hidden)
            .background(Color.black)
            .task {
                if case .idle = viewModel.state { viewModel.load() }
            }
            .onAppear { viewModel.resumeIfPlaying() }
            .onDisappear { viewModel.suspend() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)

        case .loaded(let shorts):
            ShortsPage(shorts: shorts, viewModel: viewModel)

        case .failed(let message):
            ContentUnavailableView {
                Label("shorts_couldnt_load".localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message.localizedMessage())
            } actions: {
                Button("retry".localized) { viewModel.load() }
                    .tint(.appGold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
}

// MARK: - Vertical pager

private struct ShortsPage: View {
    let shorts: [ShortModel]
    @ObservedObject var viewModel: ShortsViewModel

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(shorts) { short in
                    ShortCell(short: short, viewModel: viewModel)
                        .containerRelativeFrame(.vertical)
                        .id(short.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $viewModel.currentShortId)
        .background(Color.black)
        .onChange(of: viewModel.currentShortId) { _, newID in
            viewModel.activeShortChanged(to: newID)
        }
    }
}

#Preview {
    ShortsView()
}
