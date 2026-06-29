//
//  Step2DocumentView 2.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct Step2DocumentView: View {
    
    @ObservedObject var viewModel: VerificationViewModel
    @State private var showFrontCamera = false
    @State private var showBackCamera  = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Document picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("document".localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.appText)
                        
                        Menu {
                            ForEach(VerificationViewModel.documentType.allCases, id: \.self) { type in
                                Button(type.rawValue) { viewModel.selectedDocumentType = type }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedDocumentType.rawValue)
                                    .foregroundColor(.black)
                                    .font(.system(size: 15))
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appText.opacity(0.2), lineWidth: 1))
                        }
                    }
                    
                    // Front / Back side upload
                    HStack(spacing: 12) {
                        DocumentSideCard(
                            title: "front_side".localized,
                            capturedImage: viewModel.frontSideImage,
                            onTap: { showFrontCamera = true }
                        )
                        DocumentSideCard(
                            title: "back_side".localized,
                            capturedImage: viewModel.backSideImage,
                            onTap: { showBackCamera = true }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showFrontCamera) {
            CameraPickerView(image: $viewModel.frontSideImage, cameraType: .rear)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showBackCamera) {
            CameraPickerView(image: $viewModel.backSideImage, cameraType: .rear)
                .presentationDetents([.large])
        }
        .errorAlert(error: $viewModel.error)
    }
}

// MARK: - Document Side Card
private struct DocumentSideCard: View {
    let title: String
    let capturedImage: UIImage?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appText.opacity(0.85))
            
            Button(action: onTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appText.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .frame(height: 90)
                    
                    if let image = capturedImage {
                        // Show the captured photo
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        // Default illustration
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color(red: 0.95, green: 0.45, blue: 0.25), Color(red: 0.85, green: 0.30, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding(10)
                        
                        if title == "front_side".localized {
                            HStack(spacing: 8) {
                                Image(.frontSideProfile)
                                VStack(spacing: 5) {
                                    ForEach(0..<3) { _ in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.appText.opacity(0.5))
                                            .frame(height: 6)
                                    }
                                }
                            }
                            .padding(20)
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 2) {
                                    ForEach(0..<8) { _ in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.appText.opacity(0.6))
                                            .frame(width: 2, height: 14)
                                    }
                                }
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.appText.opacity(0.1))
                                    .frame(height: 20)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}
