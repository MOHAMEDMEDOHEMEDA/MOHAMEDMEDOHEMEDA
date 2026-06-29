//
//  ProfileImageView.swift
//  Binbon
//
//  Created by Salah Khaled on 28/04/2026.
//

import SwiftUI
import Combine
import PhotosUI

// MARK: - ViewModel
@MainActor
final class ProfileImageViewModel: ObservableObject {
    
    @Published var initialImage: UIImage? = nil
    @Published var uploadImage: UIImage? = nil
    
    @Published var showImageSheet: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var showCamera: Bool = false
    @Published var photoPickerItem: PhotosPickerItem? = nil
    
    func handlePhotoPickerItem(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.uploadImage = image
            }
        }
    }
}

// MARK: - Profile Image View
struct ProfileImageView: View {
    
    @ObservedObject var viewModel: ProfileImageViewModel
    
    var size: CGFloat = 100
    var cornerRadius: CGFloat = 20
    
    var body: some View {
        
        let displayedImage = viewModel.uploadImage ?? viewModel.initialImage
        
        ProfileImageView.widget(image: displayedImage, size: size, cornerRadius: cornerRadius)
            .onTapGesture { viewModel.showImageSheet = true }
            .confirmationDialog("choose_photo".localized,
                                isPresented: $viewModel.showImageSheet,
                                titleVisibility: .visible) {
                Button("choose_from_library".localized) { viewModel.showPhotoPicker = true }
                Button("take_a_photo".localized)        { viewModel.showCamera = true }
                Button("cancel".localized, role: .cancel) {}
            }
                                .photosPicker(isPresented: $viewModel.showPhotoPicker,
                                              selection: $viewModel.photoPickerItem,
                                              matching: .images)
                                .onChange(of: viewModel.photoPickerItem) { _, newValue in
                                    viewModel.handlePhotoPickerItem(newValue)
                                }
                                .sheet(isPresented: $viewModel.showCamera) {
                                    CameraPickerView(image: $viewModel.uploadImage, cameraType: .front)
                                        .presentationDetents([.large])
                                }
    }
    
    // MARK: - Widget
    static func widget(image: UIImage?, size: CGFloat = 100, cornerRadius: CGFloat = 20) -> some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size / 4)
                    .foregroundColor(.appText.opacity(0.6))
            }
        }
        .frame(width: size, height: size)
        .background(Color.appText.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 6))
        .padding(size > 50 ? 8 : 6)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                // Themed ring: neutral ink on Light / Dark, brand
                // gold→orange on Colored — no hard-coded pink/purple.
                .strokeBorder(
                    AppColor.goldAccentGradient,
                    lineWidth: size > 50 ? 3 : 2
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ProfileImageView(viewModel: ProfileImageViewModel())
        .background(Color.black)
}



// MARK: - Profile Image Field
struct ProfileImageField: View {
    
    let onImageSelected: (UIImage) -> Void
    @State private var showImageSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        Button {
            showImageSheet = true
        } label: {
            HStack {
                Image(systemName: "arrowshape.up.fill")
                Spacer()
                Text("jpg_png".localized)
                    .font(.footnote.weight(.medium))
            }
            .foregroundStyle(.appText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 12).stroke(.appText.opacity(0.2), lineWidth: 1)
        )
        .confirmationDialog("choose_photo".localized,
                            isPresented: $showImageSheet,
                            titleVisibility: .visible) {
            Button("choose_from_library".localized) { showPhotoPicker = true }
            Button("take_a_photo".localized) { showCamera = true }
            Button("cancel".localized, role: .cancel) {}
        }
                            .photosPicker(isPresented: $showPhotoPicker,
                                          selection: $photoPickerItem,
                                          matching: .images)
                            .onChange(of: photoPickerItem) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        onImageSelected(image)
                                    }
                                }
                            }
                            .sheet(isPresented: $showCamera) {
                                CameraPickerView(image: .init(
                                    get: { nil },
                                    set: { if let image = $0 { onImageSelected(image) } }
                                ), cameraType: .front)
                                .presentationDetents([.large])
                            }
    }
}
