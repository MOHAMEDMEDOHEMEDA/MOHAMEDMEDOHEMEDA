//
//  NewPostView.swift
//  Binbon
//
//  The "New post" composer, presented from the Posts feed. Pick multiple photos
//  from the library, then "Post" shows a 3s loading overlay and hands the post
//  back to the feed.
//

import SwiftUI
import PhotosUI
import AVFoundation
import CoreTransferable
import UniformTypeIdentifiers

struct NewPostView: View {

    var myAvatar = "media-reel-1"
    /// Called with the caption + picked media once posting completes.
    var onPost: (String, [PickedMedia]) -> Void = { _, _ in }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var theme = ThemeManager.shared

    @State private var text = ""
    @FocusState private var isEditorFocused: Bool

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var pickedMedia: [PickedMedia] = []
    @State private var draggingMediaId: UUID?
    @State private var isPosting = false

    /// Maximum characters allowed in a post.
    private let maxCharacters = 280

    private var canPost: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !pickedMedia.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    authorRow
                    messageField
                    mediaStrip
                }
                .padding(.bottom, 24)
            }

            attachmentBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .loadingOverlay(isPosting)
        .onAppear { isEditorFocused = true }
        .onChange(of: pickerItems) { _, items in loadPicked(items) }
        .onChange(of: text) { _, newValue in
            // Cap the input; typing stops once the max is reached.
            if newValue.count > maxCharacters {
                text = String(newValue.prefix(maxCharacters))
            }
        }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.appText)
            }

            Text("new_post".localized)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.appText)

            Spacer()

            Button(action: submit) {
                Text("post_action".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(AppColor.buttonGradient))
                    .opacity(canPost ? 1 : 0.4)
            }
            .buttonStyle(.plain)
            .disabled(!canPost || isPosting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Author + audience
    private var authorRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(myAvatar)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text("you".localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.appText)

                audiencePill
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var audiencePill: some View {
        HStack(spacing: 6) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 13, weight: .semibold))
            Text("everyone".localized)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(AppColor.gold)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().stroke(AppColor.gold, lineWidth: 1.5))
    }

    // MARK: - Message field
    // A vertically-growing field: it wraps to a new line and pushes the images
    // below it down as more text is typed.
    private var messageField: some View {
        TextField("whats_on_your_mind".localized, text: $text, axis: .vertical)
            .focused($isEditorFocused)
            .font(.system(size: 18))
            .foregroundStyle(.appText)
            .tint(AppColor.gold)
            .lineLimit(1...)
            .padding(.horizontal, 16)
    }

    // MARK: - Selected media (horizontal scroll; long-press to reorder)
    private var mediaStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(pickedMedia) { media in
                    mediaThumbnail(media)
                        .opacity(draggingMediaId == media.id ? 0.4 : 1)
                        .onDrag {
                            draggingMediaId = media.id
                            return NSItemProvider(object: media.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: MediaReorderDelegate(
                                item: media, list: $pickedMedia, dragging: $draggingMediaId
                            )
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func mediaThumbnail(_ media: PickedMedia) -> some View {
        if let ui = UIImage(data: media.previewData) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                // Play badge marks video picks.
                .overlay {
                    if media.isVideo {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button { pickedMedia.removeAll { $0.id == media.id } } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.black.opacity(0.45)))
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
        }
    }

    // MARK: - Attachment toolbar
    private var attachmentBar: some View {
        HStack(spacing: 24) {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 10,
                matching: .any(of: [.images, .videos])
            ) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColor.gold)
            }

            Text("GIF")
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.appText)

            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 20))
                .foregroundStyle(.appText)

            Spacer()

            counterRing
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    /// Circular progress that fills as the user types, turning red at the limit.
    private var counterRing: some View {
        let progress = min(Double(text.count) / Double(maxCharacters), 1)
        let atLimit = text.count >= maxCharacters
        return ZStack {
            Circle()
                .stroke(Color.appText.opacity(0.25), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    atLimit ? Color.red : AppColor.gold,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 26, height: 26)
        .animation(.easeOut(duration: 0.15), value: text.count)
    }

    // MARK: - Actions

    private func loadPicked(_ items: [PhotosPickerItem]) {
        Task {
            var loaded: [PickedMedia] = []
            for item in items {
                if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                    if let video = try? await item.loadTransferable(type: VideoTransfer.self) {
                        let thumb = Self.thumbnail(for: video.url)
                        loaded.append(PickedMedia(kind: .video(url: video.url, thumbnail: thumb)))
                    }
                } else if let data = try? await item.loadTransferable(type: Data.self) {
                    loaded.append(PickedMedia(kind: .image(data)))
                }
            }
            await MainActor.run { pickedMedia = loaded }
        }
    }

    /// Grabs a still from the start of the video for the thumbnail.
    private static func thumbnail(for url: URL) -> Data {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        if let cg = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cg).jpegData(compressionQuality: 0.8) ?? Data()
        }
        return Data()
    }

    /// Shows a 3-second loading overlay, hands the post to the feed, then closes.
    private func submit() {
        guard canPost, !isPosting else { return }
        isEditorFocused = false
        isPosting = true
        let caption = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let media = pickedMedia
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            onPost(caption, media)
            dismiss()
        }
    }
}

/// Reorders the picked media as one tile is long-pressed and dragged over another.
private struct MediaReorderDelegate: DropDelegate {
    let item: PickedMedia
    @Binding var list: [PickedMedia]
    @Binding var dragging: UUID?

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != item.id,
              let from = list.firstIndex(where: { $0.id == dragging }),
              let to = list.firstIndex(where: { $0.id == item.id })
        else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            list.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}

/// Copies a picked video out of the transient PhotosPicker location into a temp
/// file we can keep and play back.
private struct VideoTransfer: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension)
            try? FileManager.default.removeItem(at: copy)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return VideoTransfer(url: copy)
        }
    }
}

#Preview {
    NewPostView()
}
