//
//  FriendReportEvidenceView.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 17/06/2026.

//

import SwiftUI
import PhotosUI

struct PickedReportImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct FriendReportEvidenceView: View {

    @Binding var images: [PickedReportImage]

    private let maxCount = 20
    private let maxBytes = 2 * 1024 * 1024
    private let thumbSize: CGFloat = 88

    @State private var showImageSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if images.count < maxCount {
                    addButton
                }

                ForEach(images) { item in
                    thumbnail(item)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
        .confirmationDialog("choose_photo".localized, isPresented: $showImageSheet) {
            Button("choose_from_library".localized) { showPhotoPicker = true }
            Button("take_a_photo".localized) { showCamera = true }
            Button("cancel".localized, role: .cancel) { }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoPickerItems,
            maxSelectionCount: maxCount - images.count,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPickedItems(items) }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(
                image: Binding(
                    get: { nil },
                    set: { image in
                        guard let image else { return }
                        appendImage(image, data: image.jpegData(compressionQuality: 0.92))
                    }
                ),
                cameraType: .rear
            )
        }
    }

    // MARK: - Add button

    private var addButton: some View {
        Button { showImageSheet = true } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.appText)
                } else {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 26, weight: .regular))
                }
            }
            .foregroundStyle(.appText.opacity(0.85))
            .frame(width: thumbSize, height: thumbSize)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appText.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.appText.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    // MARK: - Thumbnail

    private func thumbnail(_ item: PickedReportImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: thumbSize, height: thumbSize)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appText.opacity(0.15), lineWidth: 1)
                )

            Button { remove(item) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, AppColor.destructive)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
            }
            .offset(x: 8, y: -8)
            .accessibilityLabel("remove".localized)
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Import

    private func importPickedItems(_ items: [PhotosPickerItem]) async {
        isLoading = true
        defer {
            isLoading = false
            photoPickerItems.removeAll()
        }

        var rejected = 0

        for item in items {
            guard images.count < maxCount else { break }

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                rejected += 1
                continue
            }

            if !appendImage(image, data: data) {
                rejected += 1
            }
        }

        if rejected > 0 {
            Toaster.shared.show(.error(), "friend_report_evidence_import_failed".localized, 3)
        }
    }

    @discardableResult
    private func appendImage(_ image: UIImage, data: Data?) -> Bool {
        guard images.count < maxCount else { return false }

        let payload = data ?? image.jpegData(compressionQuality: 0.92) ?? Data()
        guard payload.count <= maxBytes else {
            Toaster.shared.show(.error(), "friend_report_evidence_too_large".localized, 3)
            return false
        }

        withAnimation(.easeOut(duration: 0.2)) {
            images.append(PickedReportImage(image: image))
        }
        return true
    }

    private func remove(_ item: PickedReportImage) {
        withAnimation(.easeOut(duration: 0.2)) {
            images.removeAll { $0.id == item.id }
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var images: [PickedReportImage] = []
        var body: some View {
            FriendReportEvidenceView(images: $images)
                .padding()
                .appBackground()
        }
    }
    return PreviewHost()
}
