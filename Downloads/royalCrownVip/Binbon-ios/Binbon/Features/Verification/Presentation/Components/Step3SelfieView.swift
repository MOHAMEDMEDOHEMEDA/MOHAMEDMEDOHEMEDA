//
//  Step3SelfieView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct Step3SelfieView: View {
    
    @ObservedObject var viewModel: VerificationViewModel
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("selfie_with_id_confirm".localized)
                    .font(.system(size: 15))
                    .foregroundColor(.appText.opacity(0.85))
                    .multilineTextAlignment(.center)
                
                // Camera preview / capture area
                Button(action: { showCamera = true }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [Color(red: 0.95, green: 0.45, blue: 0.2), Color(red: 0.85, green: 0.25, blue: 0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 300)
                            .padding(.horizontal, 20)
                        
                        if let image = viewModel.selfieImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipped()
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.appText)
                            }
                        }
                    }
                }
                
                Text("tap_to_open_camera".localized)
                    .font(.system(size: 12))
                    .foregroundColor(.appText.opacity(0.5))
            }
            
            Spacer()
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $viewModel.selfieImage, cameraType: .front)
                .presentationDetents([.large])
        }
        .errorAlert(error: $viewModel.error)
    }
}
