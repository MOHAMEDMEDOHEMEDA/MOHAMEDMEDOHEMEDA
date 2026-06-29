//
//  StickerPickerPanel.swift
//  Binbon
//

import SwiftUI

struct StickerItem: Identifiable {
    let id = UUID()
    let emoji: String
    let caption: String
}

struct StickerPickerPanel: View {

    let onSelect: (StickerItem) -> Void

    @State private var searchText = ""
    @State private var selectedTab = 0

    // MARK: - Mock sticker packs

    private let packs: [[StickerItem]] = [
        [
            StickerItem(emoji: "😂", caption: "قلبي يوجعني"),
            StickerItem(emoji: "😭", caption: "بطني يا عيال"),
            StickerItem(emoji: "😤", caption: "اقلب وجهك"),
            StickerItem(emoji: "🤣", caption: "ولك الووووو"),
            StickerItem(emoji: "🤯", caption: "اللللللللله"),
            StickerItem(emoji: "😩", caption: "مو قادر"),
            StickerItem(emoji: "😡", caption: "أشقك شق ترى"),
            StickerItem(emoji: "🥹", caption: "يكسر الخاطر"),
            StickerItem(emoji: "🥴", caption: "طاحت عقلي"),
        ],
        [
            StickerItem(emoji: "❤️", caption: "حبيبي"),
            StickerItem(emoji: "🔥", caption: "ناري"),
            StickerItem(emoji: "💯", caption: "مية بالمية"),
            StickerItem(emoji: "👍", caption: "تمام والله"),
            StickerItem(emoji: "🎉", caption: "مبروك مبروك"),
            StickerItem(emoji: "💪", caption: "قوي يا بطل"),
            StickerItem(emoji: "🙏", caption: "يزاك الله خير"),
            StickerItem(emoji: "😎", caption: "أنا الأفضل"),
            StickerItem(emoji: "👑", caption: "كلنا ملوك"),
        ],
    ]

    private let tabIcons = ["star.fill", "face.smiling.fill", "hand.thumbsup.fill", "bag.fill"]

    private var currentStickers: [StickerItem] {
        let base: [StickerItem]
        switch selectedTab {
        case 1: base = packs[0]
        case 2: base = packs[1]
        default: base = []
        }
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.caption.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            tabBar
            Divider().background(Color.white.opacity(0.1))
            stickerGrid
        }
        .background(Color(hex: "18181B"))
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            TextField("", text: $searchText, prompt:
                Text("sticker_search_placeholder".localized)
                    .foregroundColor(.white.opacity(0.45)))
                .font(.system(size: 14))
                .foregroundStyle(.white)
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.09))
        )
        .padding(.horizontal, 12)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Category tabs

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabIcons.count, id: \.self) { i in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedTab = i }
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        Image(systemName: tabIcons[i])
                            .font(.system(size: 19))
                            .foregroundStyle(selectedTab == i ? AppColor.gold : .white.opacity(0.38))
                        Spacer()
                        Rectangle()
                            .fill(selectedTab == i ? AppColor.gold : Color.clear)
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.18), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 46)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Sticker grid

    private var stickerGrid: some View {
        ScrollView(showsIndicators: false) {
            if currentStickers.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
                    spacing: 6
                ) {
                    ForEach(currentStickers) { sticker in
                        Button { onSelect(sticker) } label: {
                            stickerCell(sticker)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
            }
        }
    }

    private func stickerCell(_ item: StickerItem) -> some View {
        VStack(spacing: 4) {
            Text(item.emoji)
                .font(.system(size: 52))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
            Text(item.caption)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 8) {
            if selectedTab == 0 {
                Text("stickers_no_favorites".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            } else if selectedTab == 3 {
                Text("stickers_store_soon".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 36)
    }
}
