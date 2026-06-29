//
//  LoginHistoryTimeline.swift
//  Binbon
//
//  Created by Claude on 07/06/2026.
//

import SwiftUI


struct LoginHistoryTimeline: View {

    let sections: [LoginHistorySection]
    let canShowMore: Bool
    let isLoadingMore: Bool
    let onShowMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    if !section.title.isEmpty {
                        Text(section.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(section.rows) { row in
                            LoginHistoryRowView(row: row)
                        }
                    }
                }
            }

            if canShowMore {
                showMoreButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var showMoreButton: some View {
        Button(action: onShowMore) {
            HStack(spacing: 6) {
                if isLoadingMore {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Text("more".localized)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoadingMore)
    }
}

// MARK: - Row
private struct LoginHistoryRowView: View {

    let row: LoginHistoryRow

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(row.iconAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(row.time)
                    .font(.caption)
                    .foregroundStyle(Color.appGold)
            }

            Spacer(minLength: 0)

            if row.isNewDevice {
                Text("new_device_badge".localized)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.appGold.opacity(0.85), in: Capsule())
            }
        }
    }
}
