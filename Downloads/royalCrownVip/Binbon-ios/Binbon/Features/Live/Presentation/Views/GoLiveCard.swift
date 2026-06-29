//
//  GoLiveCard.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import SwiftUI

struct GoLiveCard: View {

    let hero: GoLiveHeroModel
    let onGoLive: () -> Void

    // MARK: - Layout constants
    private let cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            previewBackground
            bottomScrim
            centerCTA
            bottomChips
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppColor.gold, lineWidth: 5)
        )
    }

    private var previewBackground: some View {
        HStack(spacing: 0) {
            previewHalf(hero.primaryUser)
            previewHalf(hero.secondaryUser)
        }
        .overlay(alignment: .center) {
            Rectangle()
                .fill(AppColor.scrim)
                .frame(width: 1)
        }
    }

    private func previewHalf(_ user: LiveHeroUser?) -> some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if let imageName = user?.previewImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    AppColor.chromeButtonGradient
                }
            }
            .clipped()
    }
    
    private var bottomScrim: some View {
        LinearGradient(
            colors: [AppColor.scrim.opacity(0), AppColor.scrim],
            startPoint: .center,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var centerCTA: some View {
        VStack(spacing: 10) {
            VideoCameraIcon()
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)

            goLiveLabel

            liveButton
                .padding(.top, 4)
        }
    }

    private var goLiveLabel: some View {
        let title = "go_live".localized
        let font = Font.system(size: 25, weight: .bold, design: .rounded)

        return  Text(title)
                .font(font)
                .foregroundStyle(AppColor.gold)
       
    }
    
    private var liveButton: some View {
        Button(action: onGoLive) {
            LiveBroadcastIcon()
                   .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
 
    }

    private var bottomChips: some View {
        VStack {
            Spacer()
            HStack {
                userChip(hero.primaryUser)
                Spacer()
                if let secondary = hero.secondaryUser {
                    userChip(secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    private func userChip(_ user: LiveHeroUser) -> some View {
        HStack(spacing: 6) {
            Text(user.username)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)

            if let badge = user.badge {
                Text(badge).font(.footnote)
            }
        }
    }
    
    // MARK: - Outline offsets
    private static let outlineOffsets: [CGSize] = {
        let d: CGFloat = 1.5
        return [
            CGSize(width: -d, height: 0), CGSize(width: d, height: 0),
            CGSize(width: 0, height: -d), CGSize(width: 0, height: d),
            CGSize(width: -d, height: -d), CGSize(width: d, height: -d),
            CGSize(width: -d, height: d), CGSize(width: d, height: d)
        ]
    }()
}
