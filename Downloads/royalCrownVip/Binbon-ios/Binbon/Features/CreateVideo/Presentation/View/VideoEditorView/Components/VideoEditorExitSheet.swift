//
//  VideoEditorExitSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct VideoEditorExitSheet: View {

    var onSendToFriend: () -> Void = {}
    var onSaveDraft: () -> Void = {}
    var onDiscard: () -> Void = {}
    var onCancel: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 16) {
                Capsule().fill(Color.appText.opacity(0.3))
                    .frame(width: 40, height: 5)

                VStack(spacing: 4) {
                    Text("exit_title".localized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.appText)
                    Text("exit_subtitle".localized)
                        .font(.system(size: 13))
                        .foregroundStyle(.appText.opacity(0.6))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    row(icon: "paperplane.fill", title: "exit_send_friend".localized, action: onSendToFriend)
                    row(icon: "tray.and.arrow.down.fill", title: "exit_save_draft".localized, action: onSaveDraft)
                    row(icon: "trash.fill", title: "exit_discard".localized, tint: Color(hex: "E14554"),
                        action: onDiscard)
                }

                Button(action: onCancel) {
                    Text("cancel".localized)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.appText.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22)
                    .fill(AppColor.cardBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
            .transition(.move(edge: .bottom))
        }
    }

    private func row(icon: String, title: String, tint: Color = .appText,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 26)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 16).frame(height: 54)
            .background(Color.appText.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
