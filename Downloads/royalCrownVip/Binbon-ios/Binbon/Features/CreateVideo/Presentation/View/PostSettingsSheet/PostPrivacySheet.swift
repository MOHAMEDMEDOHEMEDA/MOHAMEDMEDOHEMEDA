//
//  PostPrivacySheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct PostPrivacySheet: View {

    @Binding var allowComments: Bool
    @Binding var allowReuse: Bool
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 18) {
            Capsule().fill(Color.appText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            HStack {
                Text("post_privacy_settings".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appText)
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

            row(icon: "bubble.right", title: "allow_comments".localized, isOn: $allowComments)
            row(icon: "arrow.2.squarepath", title: "allow_content_reuse_sub".localized, isOn: $allowReuse)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
    }

    private func row(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.appText)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.appText)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColor.toggleOnColor)
        }
    }
}
