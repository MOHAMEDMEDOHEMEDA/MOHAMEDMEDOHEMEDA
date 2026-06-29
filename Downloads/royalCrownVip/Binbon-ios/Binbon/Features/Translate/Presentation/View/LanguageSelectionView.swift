//
//  LanguageSelectionView.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI

struct LanguageSelectionView: View {
    
    @StateObject private var viewModel = LanguageSelectionViewModel()
    @ObservedObject var captionsViewModel: CaptionsViewModel
    @Environment(\.fullDismiss) private var fullDismiss
    @State private var showHint = true
    
    var body: some View {
        List {
            if showHint {
                Section {
                    HStack(alignment: .top, spacing: 8) {
                        Text("selected_languages_note".localized)
                            .font(.system(size: 14))
                            .foregroundStyle(AppColor.secondaryTextColor)
                        
                        Spacer()
                        
                        Button {
                            withAnimation { showHint = false }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColor.coinTileTitle)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 4)
                }
                .listRowBackground(AppColor.cardBackground)
            }
            
            Section {
                ForEach(viewModel.suggestedLanguages, id: \.self) { lang in
                    LanguageRow(language: lang, isSelected: viewModel.isSelected(lang)) {
                        viewModel.toggleLanguage(lang)
                    }
                    .listRowSeparator(.hidden)
                }
            } header: {
                HStack(spacing: 6) {
                    Text("suggested_languages".localized)
                        .font(.system(size: 15, weight: .semibold))
                    
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 14))
                }
                .textCase(nil)
                .padding(.bottom, 4)
            }
            .listRowBackground(AppColor.cardBackground)
            
            Section {
                ForEach(viewModel.allLanguages, id: \.self) { lang in
                    LanguageRow(language: lang, isSelected: viewModel.isSelected(lang)) {
                        viewModel.toggleLanguage(lang)
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listRowBackground(AppColor.cardBackground)
        }
        .appBackground()
        .scrollContentBackground(.hidden)
        .sheetNavigation(
            title: "do_not_translate_title".localized,
            cancelTitle: "cancel".localized,
            saveTitle: "done".localized,
            showCancel: true,
            showSave: true,
            hideBackButton: true,
            onCancel: { fullDismiss?() },
            onSave: { fullDismiss?() }
        )
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let language: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(language)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.red : AppColor.secondaryTextColor)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguageSelectionView(captionsViewModel: CaptionsViewModel())
}
