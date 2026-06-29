//
//  StoryOverlayLayer.swift
//  Binbon
//

import SwiftUI

struct StoryOverlayLayer: View {
    @Binding var overlays: [StoryOverlay]
    @Binding var selectedID: UUID?
    var addYoursMenuOverlayID: UUID?
    var onEditText: (StoryOverlay) -> Void = { _ in }
    var onEditPoll: (StoryOverlay) -> Void = { _ in }
    var onEditAddYours: (StoryOverlay) -> Void = { _ in }
    var onAddYoursEdit: (UUID) -> Void = { _ in }
    var onAddYoursSetPercent: (UUID) -> Void = { _ in }

    var body: some View {
        ZStack {
            ForEach($overlays) { $item in
                StoryOverlayItemView(
                    item: $item,
                    isSelected: selectedID == item.id,
                    showsAddYoursMenu: addYoursMenuOverlayID == item.id,
                    onSelect: { selectedID = item.id },
                    onDelete: {
                        overlays.removeAll { $0.id == item.id }
                        selectedID = nil
                    },
                    onEditText: { onEditText(item) },
                    onEditPoll: { onEditPoll(item) },
                    onEditAddYours: { onEditAddYours(item) },
                    onAddYoursEdit: { onAddYoursEdit(item.id) },
                    onAddYoursSetPercent: { onAddYoursSetPercent(item.id) }
                )
            }
        }
    }
}

private struct StoryOverlayItemView: View {
    @Binding var item: StoryOverlay
    let isSelected: Bool
    let showsAddYoursMenu: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void
    var onEditText: () -> Void
    var onEditPoll: () -> Void
    var onEditAddYours: () -> Void
    var onAddYoursEdit: () -> Void
    var onAddYoursSetPercent: () -> Void

    @State private var startPosition: CGPoint?
    @State private var startScale: CGFloat?
    @State private var startRotation: Angle?

    var body: some View {
        VStack(spacing: 6) {
            if showsAddYoursMenu {
                StoryAddYoursMenuBar(
                    onEdit: onAddYoursEdit,
                    onSetPercent: onAddYoursSetPercent
                )
            }

            if isSelected {
                overlayControls
            }

            content
                .padding(6)
                .overlay(selectionBorder)
        }
        .fixedSize(horizontal: true, vertical: true)
        .scaleEffect(item.scale)
        .rotationEffect(item.rotation)
        .offset(x: item.position.x, y: item.position.y)
        .gesture(dragGesture.simultaneously(with: magnifyGesture).simultaneously(with: rotateGesture))
        .onTapGesture {
            onSelect()
            switch item.kind {
            case .text, .mention, .hashtag:
                onEditText()
            case .poll:
                onEditPoll()
            case .addYours:
                onEditAddYours()
            default:
                break
            }
        }
    }

    private var overlayControls: some View {
        HStack {
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, .black.opacity(0.5))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            resizeHandle
        }
    }

    @ViewBuilder private var content: some View {
        switch item.kind {
        case let .text(payload):
            textView(payload)

        case let .mention(username):
            textView(StoryTextPayload(
                text: "@\(username)",
                fontName: OverlayFont.system.rawValue,
                fontSize: 22,
                colorHex: "FFFFFF",
                hasBackground: true,
                backgroundHex: "4CD964"
            ))

        case let .hashtag(tag):
            textView(StoryTextPayload(
                text: "#\(tag)",
                fontName: OverlayFont.system.rawValue,
                fontSize: 22,
                colorHex: "FFFFFF",
                hasBackground: true,
                backgroundHex: "E14554"
            ))

        case let .poll(payload):
            VStack(spacing: 10) {
                Text(payload.question)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)

                ForEach(Array(payload.options.enumerated()), id: \.offset) { index, option in
                    if payload.showResults {
                        pollResultRow(
                            option: option,
                            percent: payload.percents.indices.contains(index) ? payload.percents[index] : 0,
                            isYes: index == 0
                        )
                    } else {
                        Text(option)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.white, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(width: 220)

        case let .addYours(payload):
            VStack(alignment: .leading, spacing: 8) {
                Text(payload.prompt)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)

                addYoursSlider(payload)
            }
            .frame(width: 220)

        case let .location(name):
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text(name)
                    .lineLimit(1)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.black.opacity(0.45), in: Capsule())

        case let .liveEvent(payload):
            VStack(alignment: .leading, spacing: 8) {
                Text(payload.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                if let date = payload.date {
                    Text(date.display("MMM d HH:mm"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.black.opacity(0.7))
                }
                Text("story_live_register".localized)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(12)
            .frame(width: 180)
            .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 12))

        case let .emoji(emoji):
            Text(emoji).font(.system(size: 64))

        case let .gif(payload):
            StoryGifOverlayView(
                reference: payload.fullURL,
                fallbackAsset: payload.previewAsset
            )

        case let .image(assetName):
            Image(assetName).resizable().scaledToFit().frame(width: 80, height: 80)
        }
    }

    private func addYoursSlider(_ payload: StoryAddYoursPayload) -> some View {
        let progress = min(max(payload.sliderPercent, 0), 1)

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.black.opacity(0.68))
                .frame(width: 220, height: 40)

            GeometryReader { geo in
                let inset: CGFloat = 10
                let trackWidth = geo.size.width - inset * 2
                let fillWidth = trackWidth * progress
                let emojiRadius: CGFloat = 13
                let emojiX = min(
                    geo.size.width - inset - emojiRadius,
                    max(inset + emojiRadius, inset + fillWidth)
                )

                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: trackWidth, height: 8)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                Capsule()
                    .fill(Color.white.opacity(0.42))
                    .frame(width: max(8, fillWidth), height: 8)
                    .position(x: inset + max(4, fillWidth) / 2, y: geo.size.height / 2)

                Text(payload.emoji)
                    .font(.system(size: 22))
                    .position(x: emojiX, y: geo.size.height / 2)
            }
            .frame(width: 220, height: 40)
        }
        .frame(width: 220, height: 40)
    }

    private func textView(_ payload: StoryTextPayload) -> some View {
        Text(payload.text.isEmpty ? " " : payload.text)
            .font((OverlayFont(rawValue: payload.fontName) ?? .system).font(size: payload.fontSize))
            .foregroundStyle(Color(hex: payload.colorHex))
            .shadow(color: .black.opacity(payload.hasBackground ? 0 : 0.35), radius: 3, y: 1)
            .multilineTextAlignment(.center)
            .padding(.horizontal, payload.hasBackground ? 14 : 0)
            .padding(.vertical, payload.hasBackground ? 8 : 0)
            .background {
                if payload.hasBackground, let hex = payload.backgroundHex {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: hex))
                }
            }
    }

    private func pollResultRow(option: String, percent: Int, isYes: Bool) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 10)
                    .fill(isYes ? Color(hex: "4CD964") : Color(hex: "E14554"))
                    .frame(width: geo.size.width * CGFloat(percent) / 100)
            }

            Text("\(percent)% \(option)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
        }
        .frame(height: 40)
    }

    @ViewBuilder private var selectionBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(.white.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4]))
        }
    }

    private var resizeHandle: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.black)
            .frame(width: 26, height: 26)
            .background(Circle().fill(.white))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if startScale == nil { startScale = item.scale }
                        let delta = (value.translation.width + value.translation.height) / 160
                        item.scale = max(0.3, min(6, startScale! + delta))
                    }
                    .onEnded { _ in startScale = nil }
            )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if startPosition == nil { startPosition = item.position; onSelect() }
                item.position = CGPoint(
                    x: startPosition!.x + value.translation.width,
                    y: startPosition!.y + value.translation.height
                )
            }
            .onEnded { _ in startPosition = nil }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                if startScale == nil { startScale = item.scale }
                item.scale = max(0.3, min(5, startScale! * scale))
            }
            .onEnded { _ in startScale = nil }
    }

    private var rotateGesture: some Gesture {
        RotationGesture()
            .onChanged { angle in
                if startRotation == nil { startRotation = item.rotation }
                item.rotation = startRotation! + angle
            }
            .onEnded { _ in startRotation = nil }
    }
}
