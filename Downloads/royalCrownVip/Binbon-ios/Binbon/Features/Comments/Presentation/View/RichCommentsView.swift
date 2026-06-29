//
//  RichCommentsView.swift
//  Binbon
//
//  The comments sheet for posts & reels: a folder-tab union (Gif / Sticker /
//  Voice / Comments), per-type comment rows with replies and likes, and a
//  composer that changes per tab.
//

import SwiftUI

struct RichCommentsView: View {

    @StateObject private var viewModel = RichCommentsViewModel()

    private let earHeight: CGFloat = 52

    private var selectedIndex: Int {
        CommentTab.allCases.firstIndex(of: viewModel.selectedTab) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            tabLabelRow

            list

            composer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            CommentsUnionBackground(
                selectedIndex: selectedIndex,
                count: CommentTab.allCases.count,
                earHeight: earHeight
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear { viewModel.load() }
    }

    // MARK: - Folder tab labels (drawn over the union background)
    private var tabLabelRow: some View {
        HStack(spacing: 0) {
            ForEach(CommentTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedTab = tab }
                } label: {
                    Text(tab.title)
                        .font(.system(size: 15, weight: viewModel.selectedTab == tab ? .bold : .medium))
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: earHeight)
    }

    // MARK: - List
    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.current) { comment in
                    CommentRowView(comment: comment) { viewModel.toggleLike($0) }
                    Rectangle()
                        .fill(Color.appText.opacity(0.12))
                        .frame(height: 1)
                }
            }
            .padding(.top, 4)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Composer
    @ViewBuilder
    private var composer: some View {
        Group {
            switch viewModel.selectedTab {
            case .comments:
                HStack(spacing: 12) {
                    TextField("write_your_comment".localized, text: $viewModel.draft)
                        .font(.system(size: 15))
                        .foregroundStyle(.appText)
                        .tint(AppColor.gold)
                        .padding(.horizontal, 20)
                        .frame(height: 50)
                        .background(Capsule().fill(Color.appText.opacity(0.15)))

                    Button { viewModel.sendDraft() } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(AppColor.buttonGradient))
                    }
                    .buttonStyle(.plain)
                }

            case .gif:
                composerCircle { Text("GIF").font(.system(size: 15, weight: .heavy)) }
            case .voice:
                composerCircle { Image(systemName: "mic.fill").font(.system(size: 22)) }
            case .sticker:
                composerCircle { Image(systemName: "face.smiling").font(.system(size: 24)) }
            }
        }
        .padding(.all, 14)
    }

    private func composerCircle<Content: View>(@ViewBuilder _ glyph: () -> Content) -> some View {
        Button {
            // TODO: open the GIF / sticker picker or start voice recording.
        } label: {
            glyph()
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Circle().fill(AppColor.buttonGradient))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Comment row

private struct CommentRowView: View {
    let comment: RichComment
    var indent: CGFloat = 0
    let onLike: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(comment.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: indent > 0 ? 38 : 48, height: indent > 0 ? 38 : 48)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 8) {
                    header
                    content
                    Text("reply".localized)
                        .font(.system(size: 14))
                        .foregroundStyle(.appText.opacity(0.65))
                }

                Spacer(minLength: 8)

                likeColumn
            }
            .padding(.leading, indent)
            .padding(.all, 14)

            ForEach(comment.replies) { reply in
                CommentRowView(comment: reply, indent: indent + 44, onLike: onLike)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(comment.username)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.appText)
            Text(comment.time)
                .font(.system(size: 14))
                .foregroundStyle(.appText.opacity(0.6))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch comment.kind {
        case .text:
            textBody
        case .gif(let asset, let caption):
            VStack(alignment: .center, spacing: 8) {
                mediaImage(asset, size: 200, corner: 14)
                if !caption.isEmpty { captionBubble(caption) }
            }
        case .sticker(let asset):
            mediaImage(asset, size: 150, corner: 18)
        case .voice(let duration):
            VoicePlayerView(duration: duration)
        }
    }

    private var textBody: some View {
        var line = Text("")
        if !comment.mention.isEmpty {
            line = Text(comment.mention + " ")
                .foregroundColor(Color(red: 0.36, green: 0.66, blue: 1.0)) // mention blue
                .font(.system(size: 16, weight: .semibold))
        }
        line = line + Text(comment.text)
            .foregroundColor(.appText)
            .font(.system(size: 16, weight: comment.mention.isEmpty ? .regular : .semibold))
        return line.fixedSize(horizontal: false, vertical: true)
    }

    private func mediaImage(_ asset: String, size: CGFloat, corner: CGFloat) -> some View {
        Image(asset)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size * 0.78)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }

    private func captionBubble(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(.white))
    }

    private var likeColumn: some View {
        Button { onLike(comment.id) } label: {
            VStack(spacing: 4) {
                Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundStyle(comment.isLiked ? .red : .appText)
                Text("\(comment.likes)")
                    .font(.system(size: 14))
                    .foregroundStyle(.appText.opacity(0.85))
                    .contentTransition(.numericText())
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Voice player

private struct VoicePlayerView: View {
    let duration: String

    /// Static bar heights for the waveform (deterministic, no Date/random).
    private let heights: [CGFloat] = [8, 14, 20, 11, 24, 16, 9, 22, 13, 18, 10, 26, 15, 12, 20, 8, 17, 23, 11, 14, 19, 9, 21, 13]

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "play.fill")
                .font(.system(size: 16))
                .foregroundStyle(.appText)

            HStack(spacing: 2) {
                ForEach(Array(heights.enumerated()), id: \.offset) { _, h in
                    Capsule()
                        .fill(Color.appText.opacity(0.85))
                        .frame(width: 2.5, height: h)
                }
            }
            .frame(height: 26)

            Text(duration)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.appText.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.appText.opacity(0.15)))
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            RichCommentsView()
                .presentationDetents([.large])
        }
}
