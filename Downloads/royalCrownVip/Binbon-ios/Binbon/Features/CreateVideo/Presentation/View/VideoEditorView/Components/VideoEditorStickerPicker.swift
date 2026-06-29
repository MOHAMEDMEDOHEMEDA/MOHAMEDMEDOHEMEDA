//
//  VideoEditorStickerPicker.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoEditorStickerPicker: View {

    var initialTab: Tab = .stickers
    var onPick: (String) -> Void
    var onPickGif: ((StoryGifItem) -> Void)? = nil
    var onClose: () -> Void = {}

    enum Tab: String, CaseIterable, Identifiable {
        case favourites, stickers, gif
        var id: String { rawValue }
        var title: String {
            switch self {
            case .favourites: return "stk_favourites".localized
            case .stickers:   return "stk_stickers".localized
            case .gif:        return "stk_gif".localized
            }
        }
    }

    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var gifViewModel = StoryGifPickerViewModel()
    @State private var tab: Tab
    @State private var categoryIndex = 0
    @AppStorage("sticker_recents") private var recentsRaw = ""
    @Namespace private var tabUnderline

    private let emojiColumns = Array(repeating: GridItem(.flexible()), count: 6)
    private let gifColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    init(
        initialTab: Tab = .stickers,
        onPick: @escaping (String) -> Void,
        onPickGif: ((StoryGifItem) -> Void)? = nil,
        onClose: @escaping () -> Void = {}
    ) {
        self.initialTab = initialTab
        self.onPick = onPick
        self.onPickGif = onPickGif
        self.onClose = onClose
        _tab = State(initialValue: initialTab)
    }

    private var recents: [String] {
        recentsRaw.split(separator: ",").map(String.init)
    }

    var body: some View {
        VStack(spacing: 12) {
            Capsule().fill(Color.appText.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 8)

            header

            if tab == .gif, onPickGif != nil {
                gifSearchField
            }

            switch tab {
            case .favourites: favouritesTab
            case .stickers:   stickersTab
            case .gif:        gifTab
        
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
        .task {
            if onPickGif != nil {
                await gifViewModel.loadTrending()
            }
        }
        .onChange(of: gifViewModel.query) { _, _ in
            guard onPickGif != nil else { return }
            Task { await gifViewModel.search() }
        }
    }

    private var gifSearchField: some View {
        TextField("story_gif_search_placeholder".localized, text: $gifViewModel.query)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(12)
            .background(Color.appText.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
    }

    // MARK: - Header (tabs + close)
    private var header: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { item in
                let isSelected = tab == item
                Button { withAnimation(.easeInOut(duration: 0.2)) { tab = item } } label: {
                    VStack(spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                            .foregroundStyle(isSelected ? Color.appText : Color.appText.opacity(0.5))
                        ZStack {
                            Capsule().fill(.clear).frame(height: 2)
                            if isSelected {
                                Capsule().fill(Color.appText).frame(height: 2)
                                    .matchedGeometryEffect(id: "stk_tab", in: tabUnderline)
                            }
                        }
                    }
                    .padding(.trailing, 18)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
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

    // MARK: - Stickers (emoji by category)
    private var stickersTab: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(EmojiCatalog.categories.enumerated()), id: \.offset) { index, cat in
                        let selected = index == categoryIndex
                        Button { withAnimation(.easeInOut(duration: 0.15)) { categoryIndex = index } } label: {
                            Image(systemName: cat.symbol)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(selected ? AnyShapeStyle(.white)
                                                          : AnyShapeStyle(Color.appText.opacity(0.6)))
                                .frame(width: 40, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selected ? AnyShapeStyle(AppColor.buttonGradient)
                                                       : AnyShapeStyle(Color.clear))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }

            grid(EmojiCatalog.categories[categoryIndex].emojis)
        }
    }

    // MARK: - GIF
    @ViewBuilder
    private var gifTab: some View {
        if onPickGif == nil {
            gifPlaceholder
        } else if gifViewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if gifViewModel.items.isEmpty {
            gifPlaceholder
        } else {
            ScrollView {
                LazyVGrid(columns: gifColumns, spacing: 10) {
                    ForEach(gifViewModel.items) { item in
                        Button {
                            onPickGif?(item)
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

    private var gifPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "rectangle.stack.badge.play")
                .font(.system(size: 40))
                .foregroundStyle(.appText.opacity(0.4))
            Text("stk_gif_soon".localized)
                .font(.system(size: 14))
                .foregroundStyle(.appText.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Favorites (recently used)
    @ViewBuilder private var favouritesTab: some View {
        if recents.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "star")
                    .font(.system(size: 40))
                    .foregroundStyle(.appText.opacity(0.4))
                Text("stk_fav_empty".localized)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText.opacity(0.6))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            grid(recents)
        }
    }

    // MARK: - Shared grid
    private func grid(_ emojis: [String]) -> some View {
        ScrollView {
            LazyVGrid(columns: emojiColumns, spacing: 14) {
                ForEach(Array(emojis.enumerated()), id: \.offset) { _, emoji in
                    Button {
                        addRecent(emoji)
                        onPick(emoji)
                    } label: {
                        Text(emoji).font(.system(size: 34))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func addRecent(_ emoji: String) {
        var list = recents.filter { $0 != emoji }
        list.insert(emoji, at: 0)
        if list.count > 36 { list = Array(list.prefix(36)) }
        recentsRaw = list.joined(separator: ",")
    }
}
