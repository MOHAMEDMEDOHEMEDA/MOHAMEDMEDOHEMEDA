//
//  CommentsView.swift
//  Binbon
//

import SwiftUI

/// Reusable comments thread, presented as a bottom sheet over any screen.
/// The host passes the id of the item being commented on plus its current
/// comment count for the header — nothing here is tied to a specific feed.
struct CommentsView: View {

    @StateObject private var viewModel: CommentsViewModel
    @Environment(\.dismiss) private var dismiss

    init(targetID: String, commentCount: Int = 0) {
        _viewModel = StateObject(
            wrappedValue: CommentsViewModel(targetID: targetID, initialCount: commentCount)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.commentMeta)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let comments):
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment) {
                                viewModel.toggleLike(comment.id)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)

            case .failed(let error):
                Text(error.localizedMessage())
                    .font(.system(size: 14))
                    .foregroundStyle(AppColor.commentMeta)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.commentSheetGradient)
        .task {
            if case .idle = viewModel.state { viewModel.load() }
        }
    }

    // MARK: Header
    // Title centered across the sheet with the close button pinned to the leading edge.
    private var header: some View {
        ZStack {
            Text("comments_count".localizedFormat(viewModel.commentCount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.commentText)

            HStack {
                Button(action: { dismiss() }) {
                    Image("CommentClose")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(AppColor.commentText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("close".localized)

                Spacer()
            }
        }
        .padding(.horizontal, 27)
        .padding(.vertical, 16)
        .background(.rosePink)
    }
}

// MARK: - Comment row

private struct CommentRow: View {
    let comment: CommentModel
    let onLike: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                ImageView(comment.avatarURL)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 10) {
                    commentText
                    actionRow
                }
            }
            .padding(.leading, 25)
            .padding(.trailing, 21)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(AppColor.commentSeparator)
                .frame(height: 1)
        }
    }

    // Author + comment + inline emoji reactions, flowing and wrapping as one run.
    private var commentText: Text {
        var line = Text(comment.author)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppColor.commentMeta)
        + Text("  ")
        + Text(comment.text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(AppColor.commentText)

        if !comment.reactions.isEmpty {
            line = line + Text("  " + comment.reactions.joined(separator: " "))
                .font(.system(size: 16))
        }
        return line
    }

    private var actionRow: some View {
        HStack(spacing: 22) {
            Image("CommentThumb")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(AppColor.commentMeta)

            Button(action: onLike) {
                HStack(spacing: 4) {
                    Text("\(comment.likeCount)")
                        .font(.system(size: 14, weight: .medium))
                        .contentTransition(.numericText())
                    Image("CommentHeart")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 18)
                }
                .foregroundStyle(comment.isLiked ? AppColor.commentLiked : AppColor.commentMeta)
            }
            .buttonStyle(.plain)

            Text(comment.timestamp)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.commentMeta)

            Text("reply".localized)
                .font(.system(size: 14, weight: .medium))
                .textCase(.lowercase)
                .foregroundStyle(AppColor.commentMeta)
        }
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            CommentsView(targetID: "1", commentCount: 1750)
                .presentationDetents([.fraction(0.75), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
}
