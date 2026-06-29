//
//  FlowLayout.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import SwiftUI

/// A layout that arranges its subviews in horizontal rows, wrapping to a new
/// line whenever the next subview would overflow the available width.
/// Used for tag/chip style selections (e.g. content categories).
struct FlowLayout: Layout {

    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)

        var height: CGFloat = 0
        for (index, row) in rows.enumerated() {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight
            if index < rows.count - 1 { height += lineSpacing }
        }
        return CGSize(width: maxWidth == .infinity ? 0 : maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            var x = bounds.minX

            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                // SwiftUI applies the layout direction to custom layouts, so placing
                // left-to-right here renders right-to-left automatically in RTL.
                subview.place(
                    at: CGPoint(x: x, y: y + (rowHeight - size.height) / 2),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += rowHeight + lineSpacing
        }
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentX = 0
            }
            rows[rows.count - 1].append(subview)
            currentX += size.width + spacing
        }
        return rows
    }
}
