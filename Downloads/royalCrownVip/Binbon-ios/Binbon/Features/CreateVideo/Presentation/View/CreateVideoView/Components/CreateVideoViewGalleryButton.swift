//
//  CreateVideoViewGalleryButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI
import PhotosUI

struct CreateVideoViewGalleryButton: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    let chipBackground: Color

    var body: some View {
        PhotosPicker(selection: $viewModel.pickerItems,
                     maxSelectionCount: 1,
                     matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(chipBackground)
                if let image = viewModel.thumbnailImage {
                    Image(uiImage: image)
                        .frame(width: 50, height: 50)

                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(width: 50, height: 50)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.5), lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
