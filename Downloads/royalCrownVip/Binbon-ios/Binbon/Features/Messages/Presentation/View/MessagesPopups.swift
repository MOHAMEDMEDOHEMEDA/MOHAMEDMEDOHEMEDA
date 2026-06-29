//
//  MessagesPopups.swift
//  Binbon
//
//  The two header popovers anchored under the Messages pills: Mood (a theme
//  switch — dark / light / colored) and Do-Not-Disturb (night / day / always).
//

import SwiftUI

// MARK: - Mood (theme switch)

struct MoodDialog: View {

    @ObservedObject private var theme = ThemeManager.shared
    let onSelect: (AppThemeMode) -> Void

    /// Order matches the Figma popover: moon (dark) → sun (light) → palette (colored).
    private let options: [(mode: AppThemeMode, icon: String)] = [
        (.dark, "moon.fill"),
        (.light, "sun.max.fill"),
        (.colored, "paintpalette.fill")
    ]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(options, id: \.mode) { option in
                iconButton(mode: option.mode, icon: option.icon)
            }
        }
        .padding(.vertical, 14)
        .frame(width: 80)
        .background(popupBackground)
    }

    @ViewBuilder
    private func iconButton(mode: AppThemeMode, icon: String) -> some View {
        let isCurrent = theme.mode == mode
        Button { onSelect(mode) } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.white.opacity(isCurrent ? 0.22 : 0)))
                .overlay(Circle().stroke(AppColor.gold, lineWidth: isCurrent ? 1.5 : 0))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Do Not Disturb (schedule)

struct DoNotDisturbDialog: View {

    let selected: DoNotDisturbMode
    let onSelect: (DoNotDisturbMode) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(DoNotDisturbMode.selectable) { mode in
                Button { onSelect(mode) } label: {
                    Text(mode.titleKey.localized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(selected == mode ? Color.appPurple : .white)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 5)
        .frame(width: 200)
        .background(popupBackground)
    }
}

// MARK: - Row context menu (long press)

/// The action sheet shown over a conversation row on long-press: a gradient
/// rounded card stacking the row actions as gold-bordered pills.
struct MessageRowMenu: View {

    let onSelect: (MessageRowAction) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(MessageRowAction.allCases) { action in
                Button { onSelect(action) } label: {
                    Text(action.titleKey.localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(AppColor.messageMenuGradient)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .stroke(AppColor.gold, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: 219)
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(AppColor.messageMenuGradient)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
        )
    }
}

// MARK: - Add to group dialog

/// The centered "إضافة الى جروب" dialog: a gradient card with the two
/// destination options (family / agency) as gold-bordered pills.
struct AddToGroupDialog: View {

    let onSelect: (AddToGroupOption) -> Void

    var body: some View {
        VStack(spacing: 14) {
            ForEach(AddToGroupOption.allCases) { option in
                Button { onSelect(option) } label: {
                    Text(option.titleKey.localized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(AppColor.messageMenuGradient)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .stroke(AppColor.gold, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: 219)
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(AppColor.messageMenuGradient)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
        )
    }
}

// MARK: - Shared popover surface

/// The gradient rounded card used by both popovers — purple→coral with a gold
/// hairline, matching the Figma dialogs.
private var popupBackground: some View {
    RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(AppColor.verificationGradient)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.gold, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
}

#Preview {
    HStack(spacing: 30) {
        MoodDialog { _ in }
        DoNotDisturbDialog(selected: .always) { _ in }
    }
    .padding(40)
    .appBackground()
}
