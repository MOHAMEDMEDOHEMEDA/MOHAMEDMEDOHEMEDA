//
//  ReportAttachmentView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI
import PhotosUI

struct ReportAttachmentView: View {
    
    @Binding var images: [UIImage]
    
    @State private var showImageSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                if images.count < 4 {
                    Button {
                        showImageSheet = true
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.system(size: 22))
                            
                            Text("\(images.count)/4")
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(Color(hex: "9E9E9E"))
                        .frame(width: 64, height: 64)
                        .background(Color(hex: "D6D6D6"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            images.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .red)
                        }
                        .offset(x: 6, y: -6)
                    }
                }
            }
        }
        .confirmationDialog(
            "choose_photo".localized,
            isPresented: $showImageSheet
        ) {
            Button("choose_from_library".localized) {
                showPhotoPicker = true
            }
            
            Button("take_a_photo".localized) {
                showCamera = true
            }
            
            Button("cancel".localized, role: .cancel) { }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoPickerItems,
            maxSelectionCount: 4 - images.count,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, items in
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                
                photoPickerItems.removeAll()
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(
                image: Binding(
                    get: { nil },
                    set: { image in
                        if let image, images.count < 4 {
                            images.append(image)
                        }
                    }
                ),
                cameraType: .rear
            )
        }
    }
}
