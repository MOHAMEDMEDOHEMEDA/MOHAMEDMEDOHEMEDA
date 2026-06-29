//
//  VoiceCallParticipantsGrid.swift
//  Binbon
//

import SwiftUI

/// Group-call participants area: an optional pinned screen-share tile above an adaptive
/// grid of participant tiles. Tiles publish their three-dots button frame via
/// `TileButtonFrameKey` (in the `voiceCallBody` coordinate space) so the parent can render
/// the flat more-buttons layer and anchor the participant menu. Scrollable layouts (>10
/// participants) render the button in-tile instead, so it scrolls with the tile.
struct VoiceCallParticipantsGrid: View {

    let participants: [CallParticipant]
    let localParticipantID: UUID
    let isScreenSharing: Bool
    let screenShareName: String
    let isMicEnabled: Bool
    let isVideoEnabled: Bool
    let isAllRestricted: Bool
    let onOpenMenu: (UUID) -> Void

    private let tileSpacing: CGFloat = 8
    private let maxInlineParticipants = 10

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: tileSpacing),
            GridItem(.flexible(), spacing: tileSpacing)
        ]
    }

    var body: some View {
        if isScreenSharing {
            GeometryReader { geo in
                let screenShareHeight = min(geo.size.height * 0.4, 200)
                let gridHeight = geo.size.height - screenShareHeight - tileSpacing

                VStack(spacing: tileSpacing) {
                    screenShareTile(height: screenShareHeight)
                    gridContent(totalHeight: gridHeight)
                        .frame(height: gridHeight)
                }
            }
        } else {
            GeometryReader { geo in
                gridContent(totalHeight: geo.size.height)
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    private func screenShareTile(height: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            Image("shareScreen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColor.voiceCallLocalBorder, lineWidth: 2)
                )

            Text("voice_call_screen_sharing_label".localizedFormat(screenShareName))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    @ViewBuilder
    private func gridContent(totalHeight: CGFloat) -> some View {
        let count = participants.count
        let layoutCount = min(count, maxInlineParticipants)
        let rowCount = layoutCount == 2 ? 2 : Int(ceil(Double(layoutCount) / 2.0))
        let tileHeight = (totalHeight - tileSpacing * CGFloat(rowCount - 1)) / CGFloat(rowCount)
        let tileStyle: VoiceCallParticipantTile.Style = rowCount > 2 ? .compact : .featured
        let shouldScroll = count > maxInlineParticipants

        if count == 2 {
            VStack(spacing: tileSpacing) {
                ForEach(participants) { participant in
                    tile(participant, style: tileStyle, height: tileHeight, rendersInlineMoreButton: false)
                }
            }
            .frame(height: totalHeight, alignment: .top)
        } else if shouldScroll {
            let scrollRowCount = Int(ceil(Double(count) / 2.0))
            let gridContentHeight = CGFloat(scrollRowCount) * tileHeight
                + CGFloat(max(scrollRowCount - 1, 0)) * tileSpacing

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: tileSpacing) {
                    ForEach(participants) { participant in
                        // Scrollable content keeps its button in-tile so it scrolls with the
                        // tile (the flat overlay layer is fixed in the body and isn't used here).
                        tile(participant, style: tileStyle, height: tileHeight, rendersInlineMoreButton: true)
                    }
                }
                .frame(height: gridContentHeight)
                .padding(.bottom, 8)
            }
        } else {
            // Eager rows (not LazyVGrid) so all inline tiles are laid out together. Tiles do
            // NOT render their own three-dots button here — a per-tile .overlay button
            // hit-tests incorrectly for the bottom-left cell of a freshly-rendered 2×2 grid.
            // The buttons are drawn instead by the parent's flat more-buttons layer.
            let rows = stride(from: 0, to: participants.count, by: 2).map {
                Array(participants[$0 ..< min($0 + 2, participants.count)])
            }
            VStack(spacing: tileSpacing) {
                ForEach(rows, id: \.first?.id) { row in
                    HStack(spacing: tileSpacing) {
                        ForEach(row) { participant in
                            tile(participant, style: tileStyle, height: nil, rendersInlineMoreButton: false)
                        }
                        if row.count == 1 {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }

    /// `height == nil` lets the tile fill its row (flexible). A fixed height is only needed
    /// where the tile lives in scrollable content (the >10 grid) or a pinned screen-share row.
    /// `rendersInlineMoreButton` controls where the three-dots button lives: scrollable content
    /// renders it in-tile; the inline grid leaves it to the parent's flat layer and only
    /// publishes the button's frame here.
    private func tile(
        _ participant: CallParticipant,
        style: VoiceCallParticipantTile.Style,
        height: CGFloat?,
        rendersInlineMoreButton: Bool
    ) -> some View {
        let isLocal = participant.id == localParticipantID
        let showControls = !isLocal
        let tileView = VoiceCallParticipantTile(
            participant: participant,
            style: style,
            showsControls: showControls,
            isMicMuted: isLocal ? !isMicEnabled : participant.isMuted,
            isVideoOff: isLocal ? !isVideoEnabled : false,
            isRestricted: !isLocal && isAllRestricted
        )
        .frame(maxWidth: .infinity)

        return Group {
            if let height {
                tileView.frame(height: height)
            } else {
                tileView.frame(maxHeight: .infinity)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showControls && rendersInlineMoreButton {
                inlineMoreButton(participant)
            }
        }
        .background {
            if showControls && !rendersInlineMoreButton {
                framePublisher(participant)
            }
        }
    }

    /// Publishes the three-dots button's frame (in `voiceCallBody` space) for a tile that
    /// defers its button to the parent's flat layer. The rect matches the inline button's
    /// placement: 44×44 at the tile's top-trailing corner, inset by the same paddings.
    private func framePublisher(_ participant: CallParticipant) -> some View {
        GeometryReader { geo in
            let f = geo.frame(in: .named("voiceCallBody"))
            Color.clear.preference(
                key: TileButtonFrameKey.self,
                value: [participant.id: CGRect(x: f.maxX - 46, y: f.minY + 4, width: 44, height: 44)]
            )
        }
    }

    private func inlineMoreButton(_ participant: CallParticipant) -> some View {
        Button {
            onOpenMenu(participant.id)
        } label: {
            Image("calls-3dots")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("voice_call_more_options".localized)
        .padding(.top, 4)
        .padding(.trailing, 2)
        .background {
            GeometryReader { geo in
                Color.clear.preference(
                    key: TileButtonFrameKey.self,
                    value: [participant.id: geo.frame(in: .named("voiceCallBody"))]
                )
            }
        }
    }
}
