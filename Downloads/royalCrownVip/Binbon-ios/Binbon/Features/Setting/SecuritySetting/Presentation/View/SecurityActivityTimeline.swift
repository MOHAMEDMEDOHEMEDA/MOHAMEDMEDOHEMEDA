//
//  SecurityActivityTimeline.swift
//  Binbon
//
//  Created by Claude on 05/06/2026.
//

import SwiftUI


struct SecurityActivityTimeline: View {

    let sections: [SecurityActivitySection]
    let canShowMore: Bool
    let isLoadingMore: Bool
    let onShowMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                            SecurityActivityRowView(
                                row: row,
                                isLast: index == section.rows.count - 1
                            )
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
private struct SecurityActivityRowView: View {

    let row: SecurityActivityRow
    let isLast: Bool

    private let iconDiameter: CGFloat = 32

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineRail
            content
            Spacer(minLength: 0)
        }
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: iconDiameter, height: iconDiameter)

                Image(systemName: row.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "EB7048"))
            }

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: iconDiameter)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(row.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(row.relativeTime)
                .font(.caption)
                .foregroundStyle(Color.appGold)
        }
        .padding(.bottom, isLast ? 0 : 22)
    }
}
