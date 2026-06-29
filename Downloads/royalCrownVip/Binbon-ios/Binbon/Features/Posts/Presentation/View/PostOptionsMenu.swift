//
//  PostOptionsMenu.swift
//  Binbon
//
//  The "⋯" dropdown on a post (Report / Block / Delete) and the destructive
//  delete confirmation dialog. Positioned at the feed level so the menu can
//  overflow the card and a full-screen scrim can dismiss it.
//

import SwiftUI

/// Carries each card's "⋯" anchor up to the feed so the dropdown can be placed
/// right under the tapped post's button.
struct PostEllipsisAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGPoint>] = [:]
    static func reduce(value: inout [String: Anchor<CGPoint>], nextValue: () -> [String: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Dropdown

struct PostOptionsMenu: View {
    var onReport: () -> Void = {}
    var onBlock: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            row("report".localized, systemImage: "flag", action: onReport)
            divider
            row("block".localized, systemImage: "nosign", action: onBlock)
            divider
            row("delete".localized, systemImage: "trash", action: onDelete)
        }
        .frame(width: 230)
        .background(AppColor.postMenuGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColor.postMenuDivider)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    private func row(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 22)
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Delete confirmation dialog

struct DeletePostDialog: View {
    var onCancel: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(spacing: 14) {
            Text("delete_post_title".localized)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text("delete_post_message".localized)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 14) {
                Button(action: onCancel) {
                    Text("cancel".localized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColor.dialogBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Text("delete".localized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColor.destructiveRed)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 6)
        }
        .padding(24)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.dialogBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColor.dialogBorder, lineWidth: 1)
                )
        )
    }
}
