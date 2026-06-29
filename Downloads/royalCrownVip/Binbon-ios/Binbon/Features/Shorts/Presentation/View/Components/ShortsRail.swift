//
//  ShortsRail.swift
//  Binbon
//
//  The trailing engagement rail: profile (with follow badge), like, comment,
//  save, share, more, and the overflow menu. Counts come preformatted from the
//  model; only the like toggles state (heart turns red).
//

import SwiftUI

struct ShortsRail: View {
    let short: ShortModel
    let isLiked: Bool
    let onLike: () -> Void
    let onComment: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            profileButton

            Button(action: onLike) {
                railItem(systemName: "heart.fill",
                         text: short.likesText,
                         tint: isLiked ? .red : .white)
            }
            .buttonStyle(.plain)

            railButton(action: onComment) {
                railItem(image: "reels-comments", text: short.commentsText)
            }

            railButton(action: onSave) {
                railItem(systemName: "bookmark.fill", text: "shorts_save".localized)
            }

            railButton(action: onShare) {
                railItem(systemName: "arrowshape.turn.up.left.fill", text: short.sharesText)
            }

            railButton {
                railItem(systemName: "hand.thumbsup", text: "shorts_more".localized)
            }

            railButton {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(90))
                    .frame(height: 28)
                    .shadow(color: .black.opacity(0.6), radius: 6)
            }
        }
    }

    private var profileButton: some View {
        Button {
            // TODO: profile navigation — no destination spec for shorts yet.
        } label: {
            ZStack(alignment: .bottom) {
                ImageView(short.authorAvatarURL, placeholder: Image(systemName: "person.fill"))
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColor.goldAccentGradient, lineWidth: 2))

                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(AppColor.buttonGradient))
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(y: 9)
            }
        }
        .buttonStyle(.plain)
        .padding(.bottom, 6)
    }

    private func railButton<Content: View>(action: @escaping () -> Void = {},
                                           @ViewBuilder content: () -> Content) -> some View {
        Button(action: action) { content() }
            .buttonStyle(.plain)
    }

    private func railItem(systemName: String, text: String, tint: Color = .white) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(tint)
                .shadow(color: .black.opacity(0.6), radius: 8)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 4)
        }
    }

    private func railItem(image: String, text: String) -> some View {
        VStack(spacing: 4) {
            Image(image)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 8)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 4)
        }
    }
}
