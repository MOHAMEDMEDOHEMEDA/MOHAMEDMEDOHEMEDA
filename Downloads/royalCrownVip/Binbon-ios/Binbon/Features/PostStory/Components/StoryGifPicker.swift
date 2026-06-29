//
//  StoryGifPicker.swift
//  Binbon
//

import SwiftUI

struct StoryGifPicker: View {

    var onPick: (StoryGifItem) -> Void
    var onClose: () -> Void = {}

    @StateObject private var viewModel = StoryGifPickerViewModel()
    @ObservedObject private var theme = ThemeManager.shared

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.appText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            header
            searchField
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
        .task { await viewModel.loadTrending() }
        .onChange(of: viewModel.query) { _, _ in
            Task { await viewModel.search() }
        }
    }

    private var header: some View {
        HStack {
            Text("stk_gif".localized)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.appText)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appText)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    private var searchField: some View {
        TextField("story_gif_search_placeholder".localized, text: $viewModel.query)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(12)
            .background(Color.appText.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.items.isEmpty {
            Spacer()
            Text("stk_gif_soon".localized)
                .font(.system(size: 14))
                .foregroundStyle(Color.appText.opacity(0.6))
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.items) { item in
                        Button {
                            onPick(item)
                        } label: {
                            StoryGifThumbnailView(item: item)
                            .frame(height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}
