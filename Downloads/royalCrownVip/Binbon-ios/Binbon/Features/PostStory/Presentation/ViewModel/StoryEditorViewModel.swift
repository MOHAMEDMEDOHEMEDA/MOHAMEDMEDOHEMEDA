//
//  StoryEditorViewModel.swift
//  Binbon
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class StoryEditorViewModel: ObservableObject {

    @Published private(set) var draft: StoryDraft
    @Published var isLoading = false
    @Published var error: APIError?
    @Published private(set) var publishedStoryId: Int?
    @Published var selectedOverlayID: UUID?

    private let repo: StoryPublishRepoProtocol

    init(
        draft: StoryDraft,
        repo: StoryPublishRepoProtocol = StoryPublishRepo()
    ) {
        self.draft = draft
        self.repo = repo
    }

    var overlays: [StoryOverlay] {
        get { draft.overlays }
        set {
            var updated = draft
            updated.overlays = newValue
            draft = updated
        }
    }

    func publish() {
        Task { await publishAsync() }
    }

    func deselectOverlays() {
        selectedOverlayID = nil
    }

    func addOverlay(_ overlay: StoryOverlay) {
        var updated = draft
        updated.overlays.append(overlay)
        draft = updated
        selectedOverlayID = overlay.id
    }

    func updateOverlay(id: UUID, _ transform: (inout StoryOverlay) -> Void) {
        guard let index = draft.overlays.firstIndex(where: { $0.id == id }) else { return }
        var updated = draft
        transform(&updated.overlays[index])
        draft = updated
    }

    func removeOverlay(id: UUID) {
        var updated = draft
        updated.overlays.removeAll { $0.id == id }
        draft = updated
        if selectedOverlayID == id { selectedOverlayID = nil }
    }

    @discardableResult
    func beginInlineText(prefix: String) -> UUID {
        let overlay = StoryOverlay(kind: .text(StoryTextPayload(
            text: prefix,
            fontName: OverlayFont.system.rawValue,
            fontSize: 34,
            colorHex: "FFFFFF",
            hasBackground: true,
            backgroundHex: prefix == "#" ? "FBBC05" : "4CD964"
        )))
        addOverlay(overlay)
        return overlay.id
    }

    func applyText(
        _ text: String,
        font: OverlayFont,
        size: CGFloat,
        hex: String,
        hasBackground: Bool,
        backgroundHex: String,
        editingID: UUID?
    ) {
        let payload = StoryTextPayload(
            text: text,
            fontName: font.rawValue,
            fontSize: size,
            colorHex: hex,
            hasBackground: hasBackground,
            backgroundHex: backgroundHex
        )
        if let editingID {
            updateOverlay(id: editingID) { $0.kind = .text(payload) }
        } else {
            addOverlay(StoryOverlay(kind: .text(payload)))
        }
    }

    func textPayload(for id: UUID?) -> StoryTextPayload? {
        guard let id,
              let overlay = draft.overlays.first(where: { $0.id == id }),
              case let .text(payload) = overlay.kind else { return nil }
        return payload
    }

    func pollPayload(for id: UUID?) -> StoryPollPayload? {
        guard let id,
              let overlay = draft.overlays.first(where: { $0.id == id }),
              case let .poll(payload) = overlay.kind else { return nil }
        return payload
    }

    func addYoursPayload(for id: UUID?) -> StoryAddYoursPayload? {
        guard let id,
              let overlay = draft.overlays.first(where: { $0.id == id }),
              case let .addYours(payload) = overlay.kind else { return nil }
        return payload
    }

    func applyEmoji(_ emoji: String) {
        addOverlay(StoryOverlay(kind: .emoji(emoji)))
    }

    func applyGif(_ item: StoryGifItem) {
        addOverlay(StoryOverlay(kind: .gif(StoryGifPayload(
            previewURL: item.previewURL,
            fullURL: item.fullURL,
            previewAsset: item.previewAsset
        ))))
    }

    func applyPoll(_ payload: StoryPollPayload, editingID: UUID? = nil) {
        if let editingID {
            updateOverlay(id: editingID) { $0.kind = .poll(payload) }
        } else {
            addOverlay(StoryOverlay(kind: .poll(payload)))
        }
    }

    func applyAddYoursDefault() {
        addOverlay(StoryOverlay(kind: .addYours(StoryAddYoursPayload(
            prompt: "story_add_yours_ask_anything".localized,
            emoji: "😍",
            sliderPercent: 0.35
        ))))
    }

    func applyAddYours(_ payload: StoryAddYoursPayload, editingID: UUID) {
        updateOverlay(id: editingID) { $0.kind = .addYours(payload) }
    }

    func applyLocation(_ name: String) {
        addOverlay(StoryOverlay(kind: .location(name: name)))
    }

    func applyLiveEvent(date: Date, duration: TimeInterval) {
        addOverlay(StoryOverlay(kind: .liveEvent(StoryLiveEventPayload(
            title: "story_live_event_label".localized,
            date: date,
            duration: duration
        ))))
    }

    func updateFilter(_ filter: VideoFilter) {
        var updated = draft
        updated.filter = filter
        draft = updated
    }

    func updatePhotoTransform(scale: CGFloat, rotation: Angle) {
        var updated = draft
        updated.photoScale = scale
        updated.photoRotation = rotation
        draft = updated
    }

    private func publishAsync() async {
        isLoading = true
        defer { isLoading = false }

        let result = await repo.publishStory(draft: draft)
        switch result {
        case .success(let response):
            publishedStoryId = response.data?.storyId
        case .failure(let apiError):
            error = apiError
        }
    }
}
