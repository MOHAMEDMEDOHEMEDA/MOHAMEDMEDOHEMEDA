//
//  VideoActionMenuSheet.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//

import SwiftUI

/// Bottom settings sheet for a video (download, save, share, report…).
/// Presented as a native `.sheet` with detents; it owns its own
/// background/detents so the call site only needs `.sheet { … }`.
struct VideoActionMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    /// Optional hook so the host can react to a chosen action (share, report…).
    var onSelect: ((Action) -> Void)? = nil

    private let actions: [Action] = [
        .init(icon: "arrow.down.to.line", titleKey: "download"),
        .init(icon: "bookmark.fill", titleKey: "save_to_playlist"),
        .init(icon: "clock.fill", titleKey: "save_to_watch_later"),
        .init(icon: "text.badge.plus", titleKey: "add_to_playlist"),
        .init(icon: "paperplane.fill", titleKey: "share"),
        .init(icon: "flag.fill", titleKey: "report", isDestructive: true),
        .init(icon: "speaker.slash.fill", titleKey: "do_not_recommend"),
        .init(icon: "hand.raised.fill", titleKey: "block", isDestructive: true)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    Button {
                        onSelect?(action)
                        dismiss()
                    } label: {
                        row(action)
                    }
                    .buttonStyle(.plain)

                    if index < actions.count - 1 {
                        Rectangle()
                            .fill(AppColor.videoMenuDivider)
                            .frame(height: 0.5)
                            .padding(.leading, 68)
                    }
                }
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground { AppColor.videoMenuGradient }
    }

    private func row(_ action: Action) -> some View {
        let tint = action.isDestructive ? AppColor.destructive : AppColor.videoMenuText
        return HStack(spacing: 16) {
            Image(systemName: action.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(AppColor.videoMenuText.opacity(0.08), in: Circle())

            Text(action.titleKey.localized)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

extension VideoActionMenuSheet {
    /// A single row: (SF Symbol, localization key, destructive flag).
    struct Action: Identifiable {
        let id = UUID()
        let icon: String
        let titleKey: String
        var isDestructive: Bool = false
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            VideoActionMenuSheet()
                .localizer()
        }
}
