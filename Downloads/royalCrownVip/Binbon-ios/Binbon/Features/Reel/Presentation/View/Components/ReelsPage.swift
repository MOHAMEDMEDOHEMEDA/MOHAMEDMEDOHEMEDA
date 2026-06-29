//
//  ReelsPage.swift
//  Binbon
//
//  Created by Mrwan hany on 17/06/2026.
//
import SwiftUI
import Combine

struct ReelsPage: View {
    let reels: [ReelModel]
    @ObservedObject var viewModel: ReelsViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(reels) { reel in
                        ReelCell(reel: reel, viewModel: viewModel)
                            // Center as a phone-width column on iPad/large screens
                            // (black letterbox from the page background); full-bleed
                            // on phones.
                            .adaptiveContentWidth(430)
                            .containerRelativeFrame(.vertical)
                            .id(reel.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $viewModel.currentReelId)
            .background(Color.black)
            .onChange(of: viewModel.currentReelId) { _, newID in
                viewModel.activeReelChanged(to: newID)
            }
            .onChange(of: viewModel.restoreReelId) { _, target in
                guard let target else { return }
                proxy.scrollTo(target, anchor: .top)
                viewModel.currentReelId = target
                viewModel.restoreReelId = nil
                viewModel.resumeIfPlaying()
            }
        }
    }
}
