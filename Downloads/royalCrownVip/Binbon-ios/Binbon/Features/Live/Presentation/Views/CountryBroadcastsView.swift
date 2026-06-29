//
//  CountryBroadcastsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI

struct CountryBroadcastsView: View {

    @Environment(\.router) private var router
    @StateObject private var viewModel: CountryBroadcastsViewModel

    private let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 2
    )

    init(country: LiveCountry) {
        _viewModel = StateObject(
            wrappedValue: CountryBroadcastsViewModel(country: country)
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                hero
                    .padding(.top, 4)
                searchField
                newsBanner
                broadcastsGrid
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .adaptiveContentWidth()
        .appNavigation()
        .appBackground()
    }

    // MARK: - Hero
    private var hero: some View {
        VStack(spacing: 6) {
            heroFlag
            heroLabel(AppStrings.liveCountryServer.localized)
            heroLabel(viewModel.country.displayName)
        }
        .frame(maxWidth: .infinity)
    }

    private var heroFlag: some View {
        Image(viewModel.country.flagImageName)
            .resizable()
            .scaledToFill()
            .frame(width: 79, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(AppColor.gold, lineWidth: 2)
            )
    }

    private func heroLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 19, weight: .bold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
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
                    .stroke(AppColor.textPrimary, lineWidth: 1)
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

    // MARK: - Grid
    private var broadcastsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(viewModel.broadcasts) { broadcast in
                Button { open(broadcast) } label: {
                    BroadcastCardView(broadcast: broadcast)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func open(_ broadcast: LiveBroadcast) {
        // TODO: router.navigate(.liveStream(roomId: broadcast.id))
    }
}
