//
//  CountryTile.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI

struct CountryTile: View {

    let country: LiveCountry

    private static let tileSize: CGFloat = 83
    private static let tileCornerRadius: CGFloat = 5
    private static let tileBorderWidth: CGFloat = 2
    private static let flagSize = CGSize(width: 79, height: 52)
    private static let flagCornerRadius: CGFloat = 3
    private static let flagInset: CGFloat = 2

    var body: some View {
        ZStack(alignment: .top) {
            background

            VStack(spacing: 3) {
                flag
                label
            }
            .padding(Self.flagInset)
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous))
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous)
            .fill(AppColor.liveCountryCardText)
            .overlay(
                RoundedRectangle(cornerRadius: Self.tileCornerRadius, style: .continuous)
                    .strokeBorder(AppColor.gold, lineWidth: Self.tileBorderWidth)
            )
    }

    private var flag: some View {
        Color.clear
            .aspectRatio(Self.flagSize, contentMode: .fit)
            .overlay {
                Image(country.flagImageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: Self.flagCornerRadius, style: .continuous))
    }

    private var label: some View {
        Text(country.displayName)
            .font(.system(size: 13, weight: .medium))
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .frame(maxWidth: .infinity)
    }
}
