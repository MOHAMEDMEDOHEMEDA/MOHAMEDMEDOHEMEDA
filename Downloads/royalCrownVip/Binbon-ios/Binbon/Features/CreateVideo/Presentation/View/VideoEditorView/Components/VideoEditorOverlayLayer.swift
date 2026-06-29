//
//  VideoEditorOverlayLayer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoEditorOverlayLayer: View {
    @Binding var overlays: [VideoOverlayItem]
    var editable: Bool = false
    @Binding var selectedID: UUID?
    var onEditText: (VideoOverlayItem) -> Void = { _ in }

    var body: some View {
        ZStack {
            ForEach($overlays) { $item in
                VideoOverlayItemView(
                    item: $item,
                    editable: editable,
                    isSelected: editable && selectedID == item.id,
                    onSelect: { selectedID = item.id },
                    onDelete: {
                        overlays.removeAll { $0.id == item.id }
                        selectedID = nil
                    },
                    onEditText: { onEditText(item) }
                )
            }
        }
    }
}

private struct VideoOverlayItemView: View {
    @Binding var item: VideoOverlayItem
    let editable: Bool
    let isSelected: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void
    var onEditText: () -> Void

    @State private var startOffset: CGSize?
    @State private var startScale: CGFloat?
    @State private var startRotation: Angle?

    var body: some View {
        let styled = content
            .padding(6)
            .overlay(selectionBorder)
            .scaleEffect(item.scale)
            .rotationEffect(item.rotation)
            .offset(item.offset)
            .overlay(alignment: .topLeading) { deleteBadge }
            .overlay(alignment: .bottomTrailing) { resizeHandle }

        if editable {
            styled
                .gesture(dragGesture.simultaneously(with: magnifyGesture)
                                    .simultaneously(with: rotateGesture))
                .onTapGesture { onSelect(); if isTextItem { onEditText() } }
        } else {
            styled
        }
    }

    @ViewBuilder private var content: some View {
        switch item.kind {
        case let .text(string, fontName, fontSize, colorHex):
            Text(string.isEmpty ? " " : string)
                .font((OverlayFont(rawValue: fontName) ?? .system).font(size: fontSize))
                .foregroundStyle(Color(hex: colorHex))
                .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                .multilineTextAlignment(.center)
        case let .sticker(emoji):
            Text(emoji).font(.system(size: 64))
        }
    }

    private var isTextItem: Bool { if case .text = item.kind { return true }; return false }

    @ViewBuilder private var selectionBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(.white.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4]))
        }
    }

    @ViewBuilder private var deleteBadge: some View {
        if isSelected {
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, .black.opacity(0.5))
            }
            .buttonStyle(.plain)
            .offset(x: -8, y: -8)
        }
    }

    @ViewBuilder private var resizeHandle: some View {
        if isSelected {
            Image(systemName: "arrow.down.right.and.arrow.up.left")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 26, height: 26)
                .background(Circle().fill(.white))
                .offset(x: 10, y: 10)
                .gesture(
                    DragGesture()
                        .onChanged { v in
                            if startScale == nil { startScale = item.scale }
                            let delta = (v.translation.width + v.translation.height) / 160
                            item.scale = max(0.3, min(6, startScale! + delta))
                        }
                        .onEnded { _ in startScale = nil }
                )
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if startOffset == nil { startOffset = item.offset; onSelect() }
                item.offset = CGSize(width: startOffset!.width + v.translation.width,
                                     height: startOffset!.height + v.translation.height)
            }
            .onEnded { _ in startOffset = nil }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { s in
                if startScale == nil { startScale = item.scale }
                item.scale = max(0.3, min(5, startScale! * s))
            }
            .onEnded { _ in startScale = nil }
    }

    private var rotateGesture: some Gesture {
        RotationGesture()
            .onChanged { a in
                if startRotation == nil { startRotation = item.rotation }
                item.rotation = startRotation! + a
            }
            .onEnded { _ in startRotation = nil }
    }
}
