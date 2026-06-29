//
//  ReelsView.swift
//  Binbon
//

import SwiftUI
import AVKit

struct ReelsView: View {

    @StateObject private var viewModel = ReelsViewModel()
    @ObservedObject private var chromeState = ReelChromeState.shared

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .ignoresSafeArea(.all)
            .persistentSystemOverlays(.hidden)
            .task {
                if case .idle = viewModel.state {
                    viewModel.load()
                }
            }
            .onChange(of: chromeState.hostActive) { _, active in
                if active { viewModel.resumeIfPlaying() } else { viewModel.suspend() }
            }
            .onDisappear {
                viewModel.suspend()
                ReelChromeState.shared.chromeVisible = true
            }
            .onAppear { viewModel.resumeIfPlaying() }
            .appBackground()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)

        case .loaded(let reels):
            ReelsPage(reels: reels, viewModel: viewModel)

        case .failed(let message):
            ContentUnavailableView {
                Label("couldnt_load_reels".localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message.localizedMessage())
            } actions: {
                Button("retry".localized) {
                    viewModel.load()
                }
                .tint(.appGold)
            }
        }
    }
}



#Preview {
    ReelsView()
}
