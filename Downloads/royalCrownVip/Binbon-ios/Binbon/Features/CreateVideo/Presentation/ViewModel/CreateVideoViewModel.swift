//
//  CreateVideoViewModel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI
import Combine
import PhotosUI
import Photos

@MainActor
final class CreateVideoViewModel: ObservableObject {

    enum CaptureMode: String, CaseIterable, Identifiable {
        case post, live
        var id: String { rawValue }
        var title: String {
            switch self {
            case .post:  return "mode_post".localized
            case .live:  return "mode_live".localized
            }
        }
    }
    @Published var captureMode: CaptureMode = .post

    @Published var capturedPhoto: UIImage?
    @Published var photoScale: CGFloat = 1
    @Published var photoRotation: Angle = .zero

    // MARK: - State
    @Published var layout: VideoLayoutOption = .single

    @Published var pickerItems: [PhotosPickerItem] = []
    @Published private(set) var selectedImages: [UIImage] = []

    // MARK: - Capture flow
    @Published var capturedVideoURL: URL?
    @Published var bakedVideoURL: URL?
    @Published var bakedPhoto: UIImage?
    @Published var caption: String = ""
    @Published var showShareSheet = false
    @Published var showSounds = false
    @Published var selectedSound: SoundTrack?
    @Published var showTrim = false
    @Published var showEditor = false

    // MARK: - Editor state
    @Published var overlays: [VideoOverlayItem] = []
    @Published var soundVolume: Double = 1.0
    @Published var videoVolume: Double = 1.0
    @Published var voiceoverURL: URL?
    @Published var voiceoverVolume: Double = 1.0
    @Published var showPublish = false
    @Published var showPostDetails = false

    var isReviewing: Bool { capturedVideoURL != nil }

    func discardCapture() {
        capturedVideoURL = nil
        showTrim = false
        showPublish = false
    }

    func clearSelectedImage() {
        pickerItems = []
        selectedImages = []
        updateThumbnail()
    }

    var hasSelectedImage: Bool { !selectedImages.isEmpty }

    @Published private(set) var lastGalleryImage: UIImage?

    var primaryImage: UIImage? { selectedImages.first }
    @Published private(set) var thumbnailImage: UIImage?

    private func updateThumbnail() {
        thumbnailImage = selectedImages.first ?? lastGalleryImage
    }

    // MARK: - Actions
    func select(_ layout: VideoLayoutOption) {
        self.layout = layout
    }

    func loadPickedImages() async {
        var images: [UIImage] = []
        for item in pickerItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data)?.normalizedOrientation() {
                images.append(image)
            }
        }
        selectedImages = images
        updateThumbnail()
        guard capturedVideoURL == nil, let first = images.first else { return }
        presentPhotoEditor(with: first)
    }

    func presentPhotoEditor(with image: UIImage) {
        capturedPhoto = image
        photoScale = 1
        photoRotation = .zero
        overlays = []
        layout = .single
        selectedImages = []
        pickerItems = []
        thumbnailImage = image
        caption = ""
        showEditor = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.showEditor = true
        }
    }

    // MARK: - Latest library photo
    func loadLastGalleryImage() async {
        guard await ensurePhotoAccess() else { return }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        guard let asset = assets.firstObject else { return }

        if let image = await requestImage(for: asset) {
            lastGalleryImage = image
            updateThumbnail()
        }
    }

    private func ensurePhotoAccess() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        default:
            return false
        }
    }

    private func requestImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 240, height: 240),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
