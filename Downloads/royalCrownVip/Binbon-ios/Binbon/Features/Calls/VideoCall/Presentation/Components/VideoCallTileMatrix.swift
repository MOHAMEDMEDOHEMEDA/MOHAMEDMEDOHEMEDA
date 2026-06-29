//  VideoCallTileMatrix.swift
//  Binbon

import SwiftUI

/// Adaptive tile grid for video calls, matching the Figma layout spec.
///
/// - n=1   : single tile, full screen.
/// - n=2   : 2 full-width rows stacked (1 column).
/// - n=3   : 1 full-width tile on top; 2 half-width tiles on the bottom row.
/// - n=4–8 : 2-column rows that fill the available height. Odd counts leave
///           the right cell of the last row black, matching Figma.
/// - n≥9   : compact 3- or 4-column scrollable grid with near-square tiles
///           (height = width × 0.957, per Figma node 2354:44394, 178 ÷ 186).
///
/// n=1…8 are all rendered by a single `AdaptiveTileLayout` over one
/// `ForEach(participants, id: id)`. They used to be separate `if/else` view
/// branches, but switching branch as a participant joined (1→2, 2→3, 3→4) tore
/// down the whole subtree — including the local tile's `CameraPreviewView`,
/// which re-attached the running `AVCaptureSession` to a fresh preview layer on
/// the main thread and froze the UI (the n=2/3/4 freeze). With one container the
/// tiles keep identity, so adding a participant only builds the newcomer and
/// repositions the rest — no teardown, no camera-session thrash.
struct VideoCallTileMatrix<Tile: View>: View {

    let participants: [VideoCallParticipant]
    let geometrySize: CGSize
    let gapInset: CGFloat
    let tile: (VideoCallParticipant) -> Tile

    init(
        participants: [VideoCallParticipant],
        geometrySize: CGSize,
        gapInset: CGFloat,
        @ViewBuilder tile: @escaping (VideoCallParticipant) -> Tile
    ) {
        self.participants = participants
        self.geometrySize = geometrySize
        self.gapInset = gapInset
        self.tile = tile
    }

    var body: some View { layout }

    /// Renders one tile with a stable identity keyed by the participant id.
    @ViewBuilder
    private func cell(_ participant: VideoCallParticipant) -> some View {
        tile(participant).id(participant.id)
    }

    // MARK: - Layout Selector

    @ViewBuilder
    private var layout: some View {
        let n = participants.count
        if n == 0 {
            Color.black
        } else if n <= 8 {
            AdaptiveTileLayout(spacing: 2) {
                ForEach(participants, id: \.id) { participant in
                    tile(participant)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
        } else {
            compactGrid
        }
    }

    // MARK: - n≥9 — Compact scrollable grid

    private var compactGrid: some View {
        let n     = participants.count
        let nCols = n > 15 ? 4 : 3
        let tileW = (geometrySize.width - CGFloat(nCols - 1) * 2) / CGFloat(nCols)
        let tileH = tileW * 0.957
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 2) {
                let rows = (n + nCols - 1) / nCols
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<nCols, id: \.self) { col in
                            let idx = row * nCols + col
                            if idx < n {
                                cell(participants[idx])
                                    .frame(width: tileW, height: tileH)
                                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                            } else {
                                Color.black.frame(width: tileW, height: tileH)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, gapInset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Adaptive tile layout (n=1…8)

/// One container that positions 1–8 tiles per the Figma spec. Using a single
/// `Layout` instead of per-count view branches keeps tile identity stable as
/// participants join, so the local `CameraPreviewView` is never torn down and
/// re-created (the source of the n=2/3/4 freeze).
private struct AdaptiveTileLayout: Layout {

    var spacing: CGFloat = 2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let n = subviews.count
        guard n > 0 else { return }
        let w = bounds.width
        let h = bounds.height
        let g = spacing

        func place(_ index: Int, _ rect: CGRect) {
            guard index < subviews.count else { return }
            subviews[index].place(
                at: CGPoint(x: rect.minX, y: rect.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: rect.width, height: rect.height)
            )
        }

        switch n {
        case 1:
            place(0, bounds)

        case 2:
            let rowH = (h - g) / 2
            place(0, CGRect(x: bounds.minX, y: bounds.minY, width: w, height: rowH))
            place(1, CGRect(x: bounds.minX, y: bounds.minY + rowH + g, width: w, height: rowH))

        case 3:
            let rowH = (h - g) / 2
            let cellW = (w - g) / 2
            let bottomY = bounds.minY + rowH + g
            place(0, CGRect(x: bounds.minX, y: bounds.minY, width: w, height: rowH))
            place(1, CGRect(x: bounds.minX, y: bottomY, width: cellW, height: rowH))
            place(2, CGRect(x: bounds.minX + cellW + g, y: bottomY, width: cellW, height: rowH))

        default:
            // 4…8: two-column rows. An odd last cell is left unplaced so the
            // black background shows through (matches Figma).
            let rows = (n + 1) / 2
            let rowH = (h - g * CGFloat(rows - 1)) / CGFloat(rows)
            let cellW = (w - g) / 2
            for i in 0..<n {
                let row = i / 2
                let col = i % 2
                let x = bounds.minX + (col == 0 ? 0 : cellW + g)
                let y = bounds.minY + CGFloat(row) * (rowH + g)
                place(i, CGRect(x: x, y: y, width: cellW, height: rowH))
            }
        }
    }
}
