//
//  SoundsSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SoundsSheet: View {

    @Binding var selected: SoundTrack?
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var preview = AudioPreviewPlayer()
    @State private var tab: SoundsTab = .forYou
    @State private var searching = false
    @State private var query = ""
    @State private var previewingID: UUID?

    private var results: [SoundTrack] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return SoundTrack.samples }
        return SoundTrack.samples.filter {
            $0.title.lowercased().contains(q) || $0.artist.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.appText.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 14)

            SoundsSheetTabBar(selection: $tab) {
                withAnimation(.easeInOut(duration: 0.2)) { searching.toggle() }
                if !searching { query = "" }
            }
            .padding(.horizontal, 20)

            if searching {
                SoundsSheetSearchField(query: $query)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Divider()
                .overlay(Color.appText.opacity(0.12))
                .padding(.top, 12)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(results) { track in
                        SoundsSheetRow(track: track,
                                       isSelected: selected?.id == track.id,
                                       isPlaying: previewingID == track.id,
                                       onPreview: { togglePreview(track) },
                                       onTap: { select(track) })
                        Divider()
                            .overlay(Color.appText.opacity(0.08))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
        .presentationDetents([ .large,.medium])
        .presentationDragIndicator(.hidden)
        .onDisappear { preview.stop() }
    }

    private func select(_ track: SoundTrack) {
        preview.stop()
        previewingID = nil
        selected = (selected?.id == track.id) ? nil : track
    }

    private func togglePreview(_ track: SoundTrack) {
        if previewingID == track.id {
            preview.stop()
            previewingID = nil
        } else {
            preview.play(fileName: track.fileName)
            previewingID = track.id
        }
    }
}
