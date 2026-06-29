//
//  ShareProfileView.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import SwiftUI

struct ShareProfileView: View {
    
    @StateObject var viewModel = ShareProfileViewModel()
    
    var body: some View {
        
        content
            .appBackground()
            .appNavigation(title: "share_profile".localized)
            .onAppear {
                viewModel.fetchShareDetail()
            }
    }
    
    var content: some View {
        contentBody
            .adaptiveContentWidth()
    }

    @ViewBuilder
    var contentBody: some View {
        Group {
            if viewModel.isLoading && viewModel.shareResponse == nil {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.shareResponse == nil {
                errorView
            } else {
                shareSection
            }
        }
    }
    
    var errorView: some View {
        VStack(spacing: 16) {
            Text(viewModel.error?.message ?? "failed_load_share_link".localized)
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.fetchShareDetail()
            } label: {
                Text("retry".localized)
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.appText.opacity(0.2))
                    )
            }
        }
        .padding()
    }
    
    var shareSection: some View {
        VStack(spacing: 14) {
            
            Button {
                viewModel.copyURL()
            } label: {
                HStack {
                    Text(viewModel.shareResponse?.shareUrl ?? "")
                        .foregroundStyle(.appText)
                        .font(.footnote)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "square.on.square")
                        .foregroundStyle(.appText)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).stroke(.appText, lineWidth: 1))
            }
            .buttonStyle(.plain)
            
            
            Button {
                viewModel.shareProfile()
            } label: {
                HStack {
                    Spacer()
                    Text("share_via".localized)
                        .foregroundStyle(.appText)
                        .font(.footnote)
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.black.opacity(0.1))
                        .stroke(.appText, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationView {
        ShareProfileView()
    }
}
