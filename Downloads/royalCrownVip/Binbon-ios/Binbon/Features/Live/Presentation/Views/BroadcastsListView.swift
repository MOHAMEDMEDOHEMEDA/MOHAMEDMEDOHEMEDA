//
//  BroadcastsListView.swift
//  Binbon
//
//  Created by Aya Mashaly on 14/06/2026.
//

import SwiftUI

struct BroadcastsListView: View {

    @Environment(\.router) private var router
    @StateObject private var viewModel: BroadcastsListViewModel
    // Repaint the whole screen (banner, tabs, cards) when the theme switches.
    @ObservedObject private var theme = ThemeManager.shared

    var topInset: CGFloat = 12

    /// Thickness of the gold lattice lines drawn between and around the cells.
    private let gridLine: CGFloat = 4
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: gridLine), count: 2)
    }

    // MARK: - Init
    init(initialCategory: LiveCategoryKind) {
        _viewModel = StateObject(
            wrappedValue: BroadcastsListViewModel(initialCategory: initialCategory)
        )
        
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    searchField
                    .padding(.top, 15)
                    newsBanner
                    categoryTabs
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .adaptiveContentWidth()
        .appNavigation(title: "live_broadcasts_list_title".localized)
        .appBackground()
    }

    // MARK: - Search field
    private var searchField: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Text("search".localized)
                    .font(.system(size: 11, weight: .medium))
                Spacer(minLength: 0)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18, height: 18)
                    .accessibilityHidden(true)
            }
            .padding(10)
            .frame(height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppColor.secondaryTextColor, lineWidth: 1)
            )

            Button { } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 12, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("search".localized)
        }
    }

    // MARK: - News banner
    private var newsBanner: some View {
        ZStack {
            newsBackground

            VStack(spacing: 0) {
                newsTitle
                    .padding(.top, 18)
                Spacer(minLength: 8)
                newsTicker
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var newsBackground: some View {
        if let imageName = viewModel.news.backgroundImageName {
            Color.clear
                .overlay { Image(imageName).resizable().scaledToFill() }
                .clipped()
        } else {
            AppColor.chromeButtonGradient
        }
    }

    private var newsTitle: some View {
        let title = viewModel.news.titleKey.localized
        let font = Font.system(size: 30, weight: .heavy)

        return ZStack {
            ForEach(Self.titleOutlineOffsets.indices, id: \.self) { i in
                let o = Self.titleOutlineOffsets[i]
                Text(title)
                    .font(font)
                    .foregroundStyle(AppColor.textOnAccent)
                    .offset(x: o.width, y: o.height)
            }
            Text(title)
                .font(font)
                .foregroundStyle(AppColor.gold)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColor.gold)
                .offset(x: 40, y: 10)
                .accessibilityHidden(true)
        }
        .accessibilityElement()
        .accessibilityLabel(title)
    }

    private var newsTicker: some View {
        HStack(spacing: 0) {
            Text(viewModel.news.badgeKey.localized)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity)
                .background(
                    Color(hex: "B90000"),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .overlay(
                       RoundedRectangle(cornerRadius: 8, style: .continuous)
                           .stroke(AppColor.gold, lineWidth: 0.5)
                   )

            Text(viewModel.news.headlines.joined(separator: "   •   "))
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 12)
                .padding(4)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(
            AppColor.promoGradient,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }

    private static let titleOutlineOffsets: [CGSize] = {
        let d: CGFloat = 1.2
        return [
            CGSize(width: -d, height: 0), CGSize(width: d, height: 0),
            CGSize(width: 0, height: -d), CGSize(width: 0, height: d),
            CGSize(width: -d, height: -d), CGSize(width: d, height: -d),
            CGSize(width: -d, height: d), CGSize(width: d, height: d)
        ]
    }()

    // MARK: - Category tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.categories, id: \.self) { kind in
                    categoryTab(kind)
                }
            }
        }
    }

    private func categoryTab(_ kind: LiveCategoryKind) -> some View {
        let isSelected = viewModel.selectedCategory == kind
        return Button {
            viewModel.select(kind) 
        } label: {
            Text(kind.titleKey.localized)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 16)
                .frame(height: 30)
                .background {
                    let shape = isSelected
                        ? AnyShape(FolderTabOpenShape(fullTab: true, cornerRadius: 10))
                        : AnyShape(FolderTabClosedShape(fullTab: true, cornerRadius: 10))

                    if !isSelected {
                        shape.fill(AppColor.liveSubTabGradient)
                    }

                    shape.stroke(AppColor.gold, lineWidth: 1.5)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
    
    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        if viewModel.selectedCategory == .countries {
            LiveCountriesContent()
        } else {
            broadcastsGrid
        }
    }

    // MARK: - Grid
    /// One continuous gold lattice: cells sit on a gold background and are inset by
    /// `gridLine`, so the gold shows through as the internal gridlines and the outer
    /// frame. Per-card borders are off and only the outer corners are rounded.
    private var broadcastsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: gridLine) {
            ForEach(viewModel.broadcasts) { broadcast in
                Button { open(broadcast) } label: {
                    BroadcastCardView(broadcast: broadcast, cornerRadius: 0, showBorder: false)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(gridLine)
        .background(AppColor.gold)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.gold, lineWidth: gridLine)
        )
    }

    // MARK: - Actions
    private func open(_ broadcast: LiveBroadcast) {
        // TODO: router.navigate(.liveStream(roomId: broadcast.id))
    }
}
