//
//  PostDetailsView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI
import PhotosUI

struct PostDetailsView: View {

    let videoURL: URL?
    var image: UIImage? = nil
    var layout: VideoLayoutOption = .single
    var overlays: [VideoOverlayItem] = []
    var photoScale: CGFloat = 1
    var photoRotation: Angle = .zero
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    @State private var caption = ""
    @FocusState private var captionFocused: Bool

    @State private var coverImage: UIImage?
    @State private var showPreview = false
    @State private var showEditCoverDialog = false
    @State private var showFrameSelector = false
    @State private var showPhotoPicker = false
    @State private var coverPickerItem: PhotosPickerItem?

    @State private var showLocationPicker = false
    @State private var selectedLocation: String?

    @State private var showSettings = false
    @State private var showPrivacy = false
    @State private var allowComments = true
    @State private var allowReuse = true
    @State private var showMoreOptions = false

    private let suggestedLocations = ["Ta Cave", "Chez Moi", "Ironic", "Pizza For You", "Asia - World"]

    var body: some View {
        VStack(spacing: 0) {
            PostDetailsViewHeader(onClose: onClose)
            ScrollView(showsIndicators: false) {
                PostDetailsViewContent(coverImage: $coverImage,
                                       selectedLocation: $selectedLocation,
                                       caption: $caption,
                                       captionFocused: $captionFocused,
                                       videoURL: videoURL,
                                       image: image,
                                       layout: layout,
                                       suggestedLocations: suggestedLocations,
                                       onPreview: { showPreview = true },
                                       onEditCover: { showEditCoverDialog = true },
                                       onPickLocation: { showLocationPicker = true },
                                       onShowSettings: { showSettings = true },
                                       onPrivacy: { showPrivacy = true },
                                       onMoreOptions: { showMoreOptions = true })
            }
            PostDetailsViewBottomBar()
        }
        .adaptiveContentWidth()
        .appBackground()
        .safeAreaInset(edge: .bottom) {
            if captionFocused {
                HStack {
                    Spacer()
                    Button("done".localized) { captionFocused = false }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.appText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .fullScreenCover(isPresented: $showPreview) {
            PostPreviewView(videoURL: videoURL,
                            image: image,
                            layout: layout,
                            overlays: overlays,
                            authorAvatar: coverImage,
                            photoScale: photoScale,
                            photoRotation: photoRotation,
                            onClose: { showPreview = false })
                .localizedLayout()
        }
        .sheet(isPresented: $showMoreOptions) {
            PostMoreOptionsSheet(onClose: { showMoreOptions = false })
                .presentationDetents(([.medium, .large]))
                .localizedLayout()
        }
        .sheet(isPresented: $showPrivacy) {
            PostPrivacySheet(allowComments: $allowComments,
                             allowReuse: $allowReuse,
                             onClose: { showPrivacy = false })
                .presentationDetents([.height(260), .medium])
                .presentationDragIndicator(.hidden)
                .localizedLayout()
        }
        .confirmationDialog("post_edit_cover".localized,
                            isPresented: $showEditCoverDialog,
                            titleVisibility: .visible) {
            Button("cover_from_gallery".localized) { showPhotoPicker = true }
            Button("cover_from_video".localized) { showFrameSelector = true }
            Button("cancel".localized, role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $coverPickerItem, matching: .images)
        .onChange(of: coverPickerItem) {
            Task {
                if let data = try? await coverPickerItem?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    coverImage = img
                }
            }
        }
        .fullScreenCover(isPresented: $showFrameSelector) {
            if let videoURL {
                VideoFrameSelectorView(url: videoURL,
                                       onSelect: { coverImage = $0 },
                                       onClose: { showFrameSelector = false })
                .localizedLayout()
            }
        }
        .fullScreenCover(isPresented: $showLocationPicker) {
            LocationPickerView(onSelect: { selectedLocation = $0.name },
                               onClose: { showLocationPicker = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showSettings) {
            PostSettingsSheet(videoURL: videoURL,
                              image: coverImage ?? image,
                              onClose: { showSettings = false })
                .localizedLayout()
        }
    }
}
