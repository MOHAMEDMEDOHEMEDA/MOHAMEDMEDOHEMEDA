//
//  AccountSwitcherSheet.swift
//  Binbon
//
//  Account switcher pulled from the profile name chevron: the active account,
//  an "Add Binbon account" row, and a separate Logout button.
//

import SwiftUI

struct AccountSwitcherSheet: View {
    let name: String
    let username: String
    let avatarURL: String?
    var onAddAccount: () -> Void = {}
    var onLogout: () -> Void = {}

    private var initial: String {
        String(name.first ?? "?").uppercased()
    }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 0) {
                accountRow

                Divider()
                    .overlay(Color.white.opacity(0.25))

                addAccountRow
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )

            logoutButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var accountRow: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Text("@\(username)")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .lineLimit(1)

            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .foregroundStyle(.green)
        }
        .padding(16)
    }

    private var addAccountRow: some View {
        Button(action: onAddAccount) {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 24)
                Text("add_binbon_account".localized)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var logoutButton: some View {
        Button(action: onLogout) {
            HStack(spacing: 14) {
                Image(systemName: "power")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 24)
                Text("logout".localized)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundStyle(AppColor.accentRed)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var avatar: some View {
        Group {
            if let avatarURL, !avatarURL.isEmpty {
                ImageView(avatarURL)
            } else {
                ZStack {
                    AppColor.shareCopyLinkGradient
                    Text(initial)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
