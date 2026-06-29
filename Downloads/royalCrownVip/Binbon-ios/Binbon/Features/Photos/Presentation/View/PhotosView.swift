//
//  PhotosView.swift
//  Binbon
//

import SwiftUI

struct PhotosView: View {

    @Environment(\.router) var router
    @StateObject private var viewModel = PhotosViewModel()
    @State private var selectedCategory: PhotoFeedCategory = .photo
    @State private var searchText = ""
    /// The post whose comments sheet is open, if any.
    @State private var commentingPost: PhotoPostModel?

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
            .appBackground()
            .sheet(item: $commentingPost) { _ in
                RichCommentsView()
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(20)
            }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 15) {
            VStack{}
                .frame(height: 80)
            //            PhotosTopBar(searchText: $searchText, selectedCategory: $selectedCategory)
            //                .padding(.horizontal, 20)
            //                .padding(.top, 8)

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let posts):
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(posts) { post in
                            PhotoPostCard(
                                post: post,
                                onLike: { viewModel.toggleLike(post.id) },
                                onBookmark: { viewModel.toggleBookmark(post.id) },
                                onComment: { commentingPost = post },
                                onTapHeader: { router.navigate(.profile) }
                            )
                        }
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 140)
                }
                .scrollIndicators(.hidden)

            case .failed(let error):
                ContentUnavailableView {
                    Label("couldnt_load_photos".localized, systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedMessage())
                } actions: {
                    Button("retry".localized) { viewModel.load() }
                        .tint(.appGold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    PhotosView()
}
