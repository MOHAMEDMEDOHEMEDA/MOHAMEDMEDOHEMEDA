//
//  StoryOverlayMapper.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import SwiftUI

enum StoryOverlayMapper {

    static func from(video item: VideoOverlayItem) -> StoryOverlay {
        let kind: StoryOverlayKind
        switch item.kind {
        case let .text(text, fontName, fontSize, colorHex):
            kind = .text(StoryTextPayload(
                text: text,
                fontName: fontName,
                fontSize: fontSize,
                colorHex: colorHex,
                hasBackground: false,
                backgroundHex: nil
            ))
        case let .sticker(emoji):
            kind = .emoji(emoji)
        }

        return StoryOverlay(
            id: item.id,
            kind: kind,
            position: CGPoint(x: item.offset.width, y: item.offset.height),
            scale: item.scale,
            rotation: item.rotation
        )
    }

    static func videoItem(from overlay: StoryOverlay) -> VideoOverlayItem? {
        switch overlay.kind {
        case let .text(payload):
            var item = VideoOverlayItem(kind: .text(
                payload.text,
                fontName: payload.fontName,
                fontSize: payload.fontSize,
                colorHex: payload.colorHex
            ))
            item.offset = CGSize(width: overlay.position.x, height: overlay.position.y)
            item.scale = overlay.scale
            item.rotation = overlay.rotation
            return item
        case let .emoji(emoji):
            var item = VideoOverlayItem(kind: .sticker(emoji))
            item.offset = CGSize(width: overlay.position.x, height: overlay.position.y)
            item.scale = overlay.scale
            item.rotation = overlay.rotation
            return item
        default:
            return nil
        }
    }
}
