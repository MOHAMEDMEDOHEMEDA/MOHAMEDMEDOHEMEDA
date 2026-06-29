//
//  PhotoUploadTile.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI
import PhotosUI

/// A tappable rounded tile for uploading a single photo (ID copy, anchor photo,
/// …). Shows the picked image or a camera-glyph placeholder, and offers
/// library/camera choices via the same mechanism as `ProfileImageField`
/// (PhotosPicker + `CameraPickerView`). Theme-aware.
struct PhotoUploadTile: View {

    @Binding var image: UIImage?
    var size: CGFloat = 55

    @State private var showImageSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        Button {
            showImageSheet = true
        } label: {
            tile
        }
        .buttonStyle(.plain)
        .confirmationDialog("choose_photo".localized,
                            isPresented: $showImageSheet,
                            titleVisibility: .visible) {
            Button("choose_from_library".localized) { showPhotoPicker = true }
            Button("take_a_photo".localized) { showCamera = true }
            Button("cancel".localized, role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let picked = UIImage(data: data) {
                    image = picked
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $image, cameraType: .rear)
                .presentationDetents([.large])
        }
    }

    private var tile: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "camera.fill")
                    .font(.system(size: size / 2.6))
                    .foregroundStyle(AppColor.photoTileIcon)
            }
        }
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColor.photoTileFill)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
    }
}

#Preview {
    PhotoUploadTile(image: .constant(nil))
        .padding()
        .background(Color.black)
}
