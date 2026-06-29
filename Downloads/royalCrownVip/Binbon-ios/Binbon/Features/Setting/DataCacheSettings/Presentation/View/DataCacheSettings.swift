//
//  DataCacheSettings.swift
//  Binbon
//
//  Created by Husayn on 03/06/2026.
//

import SwiftUI

struct DataCacheSettings: View {
    @StateObject var viewModel = DataCacheSettingsViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
                Section("modify_the_cache".localized) { modifyTheCacheSection }
                Section("download_videos_in_a_specific_quality".localized) { downloadVideosInASpecificQualitySection }
                Section("activate_data_saving_mode".localized) { activateDataSavingModeSection }
                Section("download_personal_data".localized) { downloadPersonalDataSection }
                Section("permanently_delete_the_account".localized) { permanentlyDeleteTheAccountSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "data_cache_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchDataStorageSetting() }
        .alert("clear_cache".localized, isPresented: $viewModel.showClearCacheConfirmation) {
            Button("cancel".localized, role: .cancel) {}
            Button("clear".localized, role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("clear_cache_confirmation".localized)
        }
        .alert("delete_account_title".localized, isPresented: $viewModel.showDeleteConfirmation) {
            Button("cancel".localized, role: .cancel) {}
            Button("delete".localized, role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("delete_account_confirmation".localized)
        }
    }
    
    private var saveButton: some View {
        Button { viewModel.save() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDataNoChanges())
    }
    
    // MARK: - Sections
    private var modifyTheCacheSection: some View {
        HStack(spacing: 6) {
            Text("clear_cache".localized)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.appText)
            Spacer()
            Text("\(viewModel.cacheSize)MB")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            viewModel.showClearCacheConfirmation = true
        }
    }
    
    private var downloadVideosInASpecificQualitySection: some View {
        DynamicSelectorVertically(options: viewModel.allowedQualities, selection: $viewModel.videQualityCase)
    }
    
    private var activateDataSavingModeSection: some View {
        Toggle(isOn: $viewModel.dataSaverEnabled) {
            Text("activate_data_saving_mode".localized)
                .foregroundStyle(.appText)
                .font(.footnote.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    private var downloadPersonalDataSection: some View {
        DownloadPersonalDataPDF {
            viewModel.exportPersonalData()
        }
    }
    
    private var permanentlyDeleteTheAccountSection: some View {
        VStack (alignment: .leading,spacing: 24){
            Text("delete_account_subtitle".localized)
            .font(.footnote)
            .foregroundStyle(.appText)

            HStack {
                Spacer()
                Button {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    HStack {
                        Text("delete_account_title".localized)
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.appText.opacity(0.5))
                    .cornerRadius(12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12).stroke(.appText, lineWidth: 1)
                )
            }
        }
        
    }
}

#Preview {
    DataCacheSettings()
}

// MARK: - Profile Image Field
struct DownloadPersonalDataPDF: View {
    
    let onImageSelected: () -> Void
    
    var body: some View {
        Button {
            onImageSelected()
        } label: {
            HStack {
                Image(systemName: "arrowshape.down.fill")
                Spacer()
                Text("personal_data_will_be_uploaded_in_PDF_format".localized)
                    .font(.footnote.weight(.medium))
            }
            .foregroundStyle(.appText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 12).stroke(.appText.opacity(0.2), lineWidth: 1)
        )
    }
}

enum VideoQualityEnum: Int, DynamicOptionProtocol {
    case q4k = 0
    case q1080p = 1
    case q720p = 2
    case q480p = 3

    var title: String {
        switch self {
        case .q4k: return "download_videos_in_quality".localized + " 4K (UHD)"
        case .q1080p: return "download_videos_in_quality".localized + " 1080p (FHD)"
        case .q720p: return "download_videos_in_quality".localized + " 720p (HD)"
        case .q480p: return "download_videos_in_quality".localized + " 480p (SD)"
        }
    }

    var apiValue: String {
        switch self {
        case .q4k: return "4k"
        case .q1080p: return "1080p"
        case .q720p: return "720p"
        case .q480p: return "480p"
        }
    }

    init?(apiValue: String) {
        switch apiValue {
        case "4k": self = .q4k
        case "1080p": self = .q1080p
        case "720p": self = .q720p
        case "480p": self = .q480p
        default: return nil
        }
    }
}
