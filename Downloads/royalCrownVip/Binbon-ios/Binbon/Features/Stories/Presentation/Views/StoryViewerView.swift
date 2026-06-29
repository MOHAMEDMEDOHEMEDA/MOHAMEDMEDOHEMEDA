//
//  StoryViewerView.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI
import Combine

private let storyDurationSeconds: Double = 5.0
private let storyTickInterval: TimeInterval = 0.05

struct StoryViewerView: View {

    let data: StoryViewerData

    @Environment(\.router) private var router
    @State private var currentIndex: Int = 0
    @State private var progress: Double = 0

    private let timer = Timer.publish(every: storyTickInterval, on: .main, in: .common).autoconnect()

    private var currentItem: StoryItem? {
        guard data.items.indices.contains(currentIndex) else { return data.items.first }
        return data.items[currentIndex]
    }

    var body: some View {
        cover
            .overlay { scrim }
            .overlay { tapZones }
            .overlay(alignment: .top) { topBar }
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            .onReceive(timer) { _ in tick() }
            .onChange(of: currentIndex) { _, _ in progress = 0 }
    }

    // MARK: - Cover

    @ViewBuilder
    private var cover: some View {
        GeometryReader { proxy in
            ZStack {
                Color.appBlack
                if let name = currentItem?.coverAssetName, !name.isEmpty {
                    Image(name).resizable().scaledToFill()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private var scrim: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                .frame(height: 229)
            Spacer()
        }
        .allowsHitTesting(false)
    }

    private var tapZones: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .onTapGesture { goPrevious() }
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .onTapGesture { goNext() }
        }
    }

    // MARK: - Top: progress + author row

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 13) {
            segmentedProgressBar
            HStack(spacing: 5) {
                avatar(name: data.authorAvatarAssetName, size: 48, glyph: 22)

                VStack(alignment: .leading, spacing: 4) {
                    Text(data.authorName)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    Text(currentItem?.timeAgo ?? "")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(AppColor.storyViewerMeta)
                }

                Spacer(minLength: 0)

                Button {
                    router.back()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 29, height: 29)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 21)
        .padding(.top, 62)
    }

    private var segmentedProgressBar: some View {
        HStack(spacing: 4) {
            ForEach(Array(data.items.enumerated()), id: \.offset) { index, _ in
                segment(fill: fillRatio(for: index))
            }
        }
        .frame(height: 2)
    }

    private func segment(fill: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.35))
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, min(1, fill)) * proxy.size.width)
            }
        }
    }

    private func fillRatio(for index: Int) -> Double {
        if index < currentIndex { return 1 }
        if index > currentIndex { return 0 }
        return progress
    }

    private func tick() {
        let step = storyTickInterval / storyDurationSeconds
        let next = progress + step
        if next >= 1 {
            goNext()
        } else {
            progress = next
        }
    }

    private func goNext() {
        if currentIndex + 1 < data.items.count {
            currentIndex += 1
        } else {
            router.back()
        }
    }

    private func goPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            progress = 0
        }
    }

    // MARK: - Avatar helper

    private func avatar(name: String?, size: CGFloat, glyph: CGFloat) -> some View {
        ZStack {
            Circle().fill(AppColor.sectionSurface)
            if let name, !name.isEmpty {
                Image(name).resizable().scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: glyph))
                    .foregroundStyle(Color.appText.opacity(0.4))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
