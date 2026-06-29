//
//  DataCacheSettingsViewModel.swift
//  Binbon
//
//  Created by Husayn on 03/06/2026.
//

import UIKit
import Combine

@MainActor
final class DataCacheSettingsViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var cacheSize = 0.0
    @Published var dataSaverEnabled = false
    @Published var videQualityCase: VideoQualityEnum = .q1080p
    @Published var allowedQualities: [VideoQualityEnum] = Array(VideoQualityEnum.allCases)

    /// UI
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var showClearCacheConfirmation = false
    @Published var showDeleteConfirmation = false
    
    private let fetchDataStorageSettingsUseCase: FetchDataStorageSettingsUseCase
    private let updateDataStorageSettingsUseCase: UpdateDataStorageSettingsUseCase
    private let clearCacheUseCase: ClearCacheUseCase
    private let deleteMyAccountUseCase: DeleteMyAccountUseCase
    private let exportPersonalDataUseCase: ExportPersonalDataUseCase
    var settingStorageResponse: DataStorageSettingsResponse?

    init(
        fetchDataStorageSettingsUseCase: FetchDataStorageSettingsUseCase,
        updateDataStorageSettingsUseCase: UpdateDataStorageSettingsUseCase,
        clearCacheUseCase: ClearCacheUseCase,
        deleteMyAccountUseCase: DeleteMyAccountUseCase,
        exportPersonalDataUseCase: ExportPersonalDataUseCase
    ) {
        self.fetchDataStorageSettingsUseCase = fetchDataStorageSettingsUseCase
        self.updateDataStorageSettingsUseCase = updateDataStorageSettingsUseCase
        self.clearCacheUseCase = clearCacheUseCase
        self.deleteMyAccountUseCase = deleteMyAccountUseCase
        self.exportPersonalDataUseCase = exportPersonalDataUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchDataStorageSettingsUseCase: container.makeFetchDataStorageSettingsUseCase(),
            updateDataStorageSettingsUseCase: container.makeUpdateDataStorageSettingsUseCase(),
            clearCacheUseCase: container.makeClearCacheUseCase(),
            deleteMyAccountUseCase: container.makeDeleteMyAccountUseCase(),
            exportPersonalDataUseCase: container.makeExportPersonalDataUseCase()
        )
    }

    // MARK: - Methods
    func fetchDataStorageSetting() {
        /// Network call
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                let settings = try await fetchDataStorageSettingsUseCase.execute()
                updateField(settings)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func updateField(_ response: DataStorageSettingsResponse?) {

        settingStorageResponse = response

        cacheSize = response?.storage.cacheSizeMB ?? 0.0
        dataSaverEnabled = response?.dataSaver.enabled ?? false

        if let videoDownload = response?.videoDownload {
            allowedQualities = videoDownload.allowedQualities.compactMap { VideoQualityEnum(apiValue: $0) }

            let selectedValue = videoDownload.defaultQuality
            videQualityCase = VideoQualityEnum(apiValue: selectedValue) ?? .q1080p
        }
    }
    
    func isDataNoChanges() -> Bool {
        guard let response = settingStorageResponse else { return true }

        let originalQuality = VideoQualityEnum(apiValue: response.videoDownload.effectiveQuality ?? response.videoDownload.defaultQuality) ?? .q1080p
        let qualityMatches = videQualityCase == originalQuality
        let dataSaverMatches = dataSaverEnabled == response.dataSaver.enabled

        return qualityMatches && dataSaverMatches
    }
    
    func clearCache() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                try await clearCacheUseCase.execute()
                Storage.shared.logout()
                AppRouter.shared.root(.authSelection)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func deleteAccount() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                try await deleteMyAccountUseCase.execute()
                Storage.shared.logout()
                AppRouter.shared.root(.authSelection)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func exportPersonalData() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                let message = try await exportPersonalDataUseCase.execute()
                Toaster.shared.show(.success(), message ?? "personal_data_exported".localized)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func save() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            let request = UpdateDataStorageSettingsRequest(
                defaultQuality: videQualityCase.apiValue,
                dataSaver: dataSaverEnabled
            )

            do {
                let result = try await updateDataStorageSettingsUseCase.execute(request: request)
                updateField(result.settings)
                Toaster.shared.show(.success(), result.message ?? "data_storage_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
    
//    func signOut(_ id: Int) {
//        /// Network call
//        Task {
//            error = nil
//            deviceLoading[id] = true
//            defer { deviceLoading[id] = false }
//            
//            let response = await settingRepo.deviceLogout(id: id)
//            
//            switch response {
//            case .success(let response):
//                if response.status == true {
//                    deviceList.removeAll(where: { $0.id == id })
//                    Toaster.shared.show(.success("arrow.left.square"), response.message ?? "device_logged_out".localized)
//                } else {
//                    self.error = APIError(type: .unknown, message: response.message ?? "device_logout_failed".localized)
//                }
//            case .failure(let error):
//                self.error = error
//            }
//        }
//    }
//    
//    func signOutOthers() {
//        /// Network call
//        Task {
//            error = nil
//            logoutAllLoading = true
//            defer { logoutAllLoading = false }
//            
//            let response = await settingRepo.deviceLogoutAll()
//            
//            switch response {
//            case .success(let response):
//                if response.status == true {
//                    deviceList.removeAll(where: { $0.isActive == false })
//                    Toaster.shared.show(.success("arrow.left.square"), response.message ?? "other_devices_logged_out".localized)
//                } else {
//                    self.error = APIError(type: .unknown, message: response.message ?? "other_devices_logout_failed".localized)
//                }
//                
//            case .failure(let error):
//                self.error = error
//            }
//        }
//    }
    
}
