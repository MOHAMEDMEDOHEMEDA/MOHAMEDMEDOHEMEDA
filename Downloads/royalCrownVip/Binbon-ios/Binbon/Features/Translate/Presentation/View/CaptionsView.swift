//
//  CaptionsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//
import SwiftUI

struct CaptionsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CaptionsViewModel() 
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                contentView
            }
            .appBackground()
            .sheetNavigation(
                title: "captions".localized,
                showClose: true,
                hideBackButton: true,
                onClose: { dismiss() }
            )
            .navigationDestination(for: TranslateRoute.self) { route in
                switch route {
                case .languageselection:
                    LanguageSelectionView(captionsViewModel: viewModel)
                case .translateMore:
                    TranslateMoreView()
                }
            }
        }
        .environment(\.fullDismiss) { dismiss() }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            captionsToggleView
            translateSectionView
        }
        .padding(.top, 8)
        .adaptiveContentWidth()
    }
    
    // MARK: - Captions Toggle
    private var captionsToggleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("show_captions".localized)
                    .font(.system(size: 15))
                
                Text("speech_not_recognized".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.secondaryTextColor)
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.showCaptions)
                .labelsHidden()
                .tint(.red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
    
    // MARK: - Translate Section
    private var translateSectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("always_translate_posts".localized)
                        .font(.system(size: 15, weight: .medium))
                    
                    Text("always_translate_posts_subtitle".localized)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColor.secondaryTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.alwaysTranslatePosts)
                    .labelsHidden()
                    .tint(.red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                translateRow(
                    title: "do_not_translate".localized,
                    value: viewModel.doNotTranslateText,
                    showChevron: true,
                    destination: .languageselection
                )
                
                Divider()
                    .padding(.leading, 20)
                
                translateRow(
                    title: "translate_into".localized,
                    value: "english".localized,
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 20)
                
                translateRow(
                    title: "translate_more".localized,
                    value: nil,
                    showChevron: true,
                    destination: .translateMore
                )
            }
        }
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
    
    private func translateRow(
        title: String,
        value: String?,
        showChevron: Bool,
        destination: TranslateRoute? = nil
    ) -> some View {
        
        Button {
            if let destination {
                path.append(destination)
            }
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                if let value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                
                if showChevron {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.secondaryTextColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CaptionsView()
}

enum TranslateRoute: Hashable {
    case languageselection
    case translateMore
}
