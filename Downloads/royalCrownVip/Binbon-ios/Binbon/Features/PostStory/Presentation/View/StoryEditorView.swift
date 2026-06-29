//
//  StoryEditorView.swift
//  Binbon
//

import SwiftUI

struct StoryEditorView: View {

    @State private var showText = false
    @State private var showStickers = false
    @State private var stickerPickerTab: VideoEditorStickerPicker.Tab = .stickers
    @State private var showLocation = false
    @State private var showLiveEventSheet = false
    @State private var showPollEditor = false
    @State private var editingOverlayID: UUID?
    @State private var editingPollID: UUID?
    @State private var addYoursMenuOverlayID: UUID?
    @State private var showAddYoursPrompt = false
    @State private var showAddYoursPercent = false
    @State private var isToolRailExpanded = false
    @State private var showSettings = false
    @State private var showFilters = false

    @StateObject private var editorEffects: VideoEffectsState
    @StateObject private var viewModel: StoryEditorViewModel
    let onClose: () -> Void
    let onPublished: (StoryDraft) -> Void

    init(
        draft: StoryDraft,
        onClose: @escaping () -> Void = {},
        onPublished: @escaping (StoryDraft) -> Void = { _ in }
    ) {
        _editorEffects = StateObject(wrappedValue: VideoEffectsState(filter: draft.filter))
        _viewModel = StateObject(wrappedValue: StoryEditorViewModel(draft: draft))
        self.onClose = onClose
        self.onPublished = onPublished
    }

    var body: some View {
        GeometryReader { geo in
            let cardSize = StoryEditorLayout.cardSize(in: geo.size)

            ZStack {
                StoryEditorCanvas(draft: viewModel.draft)
                    .onTapGesture {
                        viewModel.deselectOverlays()
                        addYoursMenuOverlayID = nil
                        if showFilters {
                            withAnimation { showFilters = false }
                        }
                    }

                StoryOverlayLayer(
                    overlays: $viewModel.overlays,
                    selectedID: $viewModel.selectedOverlayID,
                    addYoursMenuOverlayID: addYoursMenuOverlayID,
                    onEditText: { overlay in
                        editingOverlayID = overlay.id
                        showText = true
                    },
                    onEditPoll: { overlay in
                        editingPollID = overlay.id
                        showPollEditor = true
                    },
                    onEditAddYours: { overlay in
                        viewModel.selectedOverlayID = overlay.id
                        addYoursMenuOverlayID = overlay.id
                    },
                    onAddYoursEdit: { id in
                        addYoursMenuOverlayID = nil
                        editingOverlayID = id
                        showAddYoursPrompt = true
                    },
                    onAddYoursSetPercent: { id in
                        addYoursMenuOverlayID = nil
                        editingOverlayID = id
                        showAddYoursPercent = true
                    }
                )
                .frame(width: cardSize.width, height: cardSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .position(x: geo.size.width / 2, y: geo.size.height / 2)

                controls(topInset: geo.safeAreaInsets.top)
                    .zIndex(50)
            }
            .overlay(alignment: .trailing) {
                toolRail
                    .padding(.trailing, 12)
            }
        }
        .overlay { editorSheets }
        .preferredColorScheme(.dark)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .onChange(of: viewModel.publishedStoryId) { _, storyId in
            guard storyId != nil else { return }
            onPublished(viewModel.draft)
        }
        .onChange(of: editorEffects.filter) { _, filter in
            viewModel.updateFilter(filter)
        }
        .sheet(isPresented: $showStickers) {
            VideoEditorStickerPicker(
                initialTab: stickerPickerTab,
                onPick: { emoji in
                    viewModel.applyEmoji(emoji)
                    showStickers = false
                },
                onPickGif: { item in
                    viewModel.applyGif(item)
                    showStickers = false
                },
                onClose: { showStickers = false }
            )
            .localizedLayout()
        }
        .fullScreenCover(isPresented: $showLocation) {
            LocationPickerView(
                onSelect: { place in
                    viewModel.applyLocation(place.name)
                    showLocation = false
                },
                onClose: { showLocation = false }
            )
            .localizedLayout()
        }
        .fullScreenCover(isPresented: $showSettings) {
            PostSettingsSheet(
                videoURL: viewModel.draft.mediaVideoURL,
                image: viewModel.draft.mediaImage,
                onClose: { showSettings = false }
            )
            .localizedLayout()
        }
    }

    @ViewBuilder
    private var editorSheets: some View {
        if showText {
            StoryTextEditorSheet(
                initialText: viewModel.textPayload(for: editingOverlayID)?.text ?? "",
                initialFont: OverlayFont(rawValue: viewModel.textPayload(for: editingOverlayID)?.fontName ?? "") ?? .system,
                initialSize: viewModel.textPayload(for: editingOverlayID)?.fontSize ?? 34,
                initialColorHex: viewModel.textPayload(for: editingOverlayID)?.colorHex ?? "FFFFFF",
                initialHasBackground: viewModel.textPayload(for: editingOverlayID)?.hasBackground ?? false,
                initialBackgroundHex: viewModel.textPayload(for: editingOverlayID)?.backgroundHex ?? "E14554",
                onCancel: {
                    if let id = editingOverlayID,
                       viewModel.textPayload(for: id)?.text == "@" || viewModel.textPayload(for: id)?.text == "#" {
                        viewModel.removeOverlay(id: id)
                    }
                    editingOverlayID = nil
                    showText = false
                },
                onDone: { text, font, size, hex, hasBackground, backgroundHex in
                    viewModel.applyText(
                        text,
                        font: font,
                        size: size,
                        hex: hex,
                        hasBackground: hasBackground,
                        backgroundHex: backgroundHex,
                        editingID: editingOverlayID
                    )
                    editingOverlayID = nil
                    showText = false
                }
            )
            .transition(.opacity)
        }

        if showPollEditor {
            StoryPollEditorSheet(
                initial: viewModel.pollPayload(for: editingPollID),
                onCancel: {
                    editingPollID = nil
                    showPollEditor = false
                },
                onDone: { payload in
                    viewModel.applyPoll(payload, editingID: editingPollID)
                    editingPollID = nil
                    showPollEditor = false
                }
            )
            .transition(.opacity)
        }

        if showLiveEventSheet {
            StoryLiveEventSheet(
                onCancel: { showLiveEventSheet = false },
                onDone: { date, duration in
                    viewModel.applyLiveEvent(date: date, duration: duration)
                    showLiveEventSheet = false
                }
            )
            .transition(.opacity)
        }

        if showAddYoursPrompt, let id = editingOverlayID, let payload = viewModel.addYoursPayload(for: id) {
            StoryAddYoursPromptSheet(
                payload: payload,
                onCancel: {
                    showAddYoursPrompt = false
                    editingOverlayID = nil
                },
                onDone: { updated in
                    viewModel.applyAddYours(updated, editingID: id)
                    showAddYoursPrompt = false
                    editingOverlayID = nil
                }
            )
            .transition(.opacity)
        }

        if showAddYoursPercent, let id = editingOverlayID, let payload = viewModel.addYoursPayload(for: id) {
            StoryAddYoursPercentSheet(
                payload: payload,
                onCancel: {
                    showAddYoursPercent = false
                    editingOverlayID = nil
                },
                onChange: { updated in
                    viewModel.applyAddYours(updated, editingID: id)
                },
                onDone: { updated in
                    viewModel.applyAddYours(updated, editingID: id)
                    showAddYoursPercent = false
                    editingOverlayID = nil
                }
            )
            .transition(.opacity)
        }
    }

    private func controls(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            topBar(topInset: topInset)
            soundPill
            Spacer()
            if showFilters {
                CreateVideoViewFilterCarousel(effects: editorEffects)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            bottomCTA
        }
    }

    private func topBar(topInset: CGFloat) -> some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.35), in: Circle())
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.top, topInset + 8)
    }

    @ViewBuilder
    private var soundPill: some View {
        if let name = viewModel.draft.soundFileName, !name.isEmpty {
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 13, weight: .semibold))
                    Text(name)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.black.opacity(0.4), in: Capsule())
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    private var toolRail: some View {
        StoryEditorToolRail(
            primaryItems: primaryToolItems,
            expandedItems: expandedToolItems,
            isExpanded: $isToolRailExpanded
        )
    }

    private var primaryToolItems: [StoryEditorToolRail.Item] {
        [
            .init(id: "settings", icon: "gearshape") {
                showSettings = true
            },
            .init(id: "text", icon: "textformat") {
                editingOverlayID = nil
                showText = true
            },
            .init(id: "stickers", icon: "face.smiling") {
                stickerPickerTab = .stickers
                showStickers = true
            },
            .init(id: "filters", icon: "camera.filters") {
                withAnimation { showFilters.toggle() }
            },
        ]
    }

    private var expandedToolItems: [StoryEditorToolRail.Item] {
        [
            .init(id: "mention", icon: "at") {
                editingOverlayID = viewModel.beginInlineText(prefix: "@")
                showText = true
            },
            .init(id: "hashtag", icon: "number") {
                editingOverlayID = viewModel.beginInlineText(prefix: "#")
                showText = true
            },
            .init(id: "poll", icon: "chart.bar") {
                editingPollID = nil
                showPollEditor = true
            },
            .init(id: "addYours", icon: "plus.circle") {
                viewModel.applyAddYoursDefault()
            },
            .init(id: "location", icon: "mappin.and.ellipse") { showLocation = true },
            .init(id: "live", icon: "calendar") { showLiveEventSheet = true },
        ]
    }

    private var bottomCTA: some View {
        Button { viewModel.publish() } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 18))
                Text("add_to_story".localized)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(AppColor.buttonGradient, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

#Preview {
    StoryEditorView(draft: StoryDraft())
}
