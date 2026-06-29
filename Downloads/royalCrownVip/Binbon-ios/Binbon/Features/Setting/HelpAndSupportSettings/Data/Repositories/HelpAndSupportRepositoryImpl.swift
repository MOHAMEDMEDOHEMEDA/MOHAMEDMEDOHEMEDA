//
//  HelpAndSupportRepositoryImpl.swift
//  Binbon
//
//  Data layer — wraps the shared `SettingRepo`, unwrapping the transport envelope.
//

import Foundation

final class HelpAndSupportRepositoryImpl: HelpAndSupportRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchSupportFaqs() async throws -> [SupportFAQ] {
        switch await settingRepo.fetchSupportFaqs() {
        case .success(let response):
            return response.data ?? []
        case .failure(let error):
            throw error
        }
    }

    func sendSuggestion(message: String) async throws {
        try ensureSuccess(await settingRepo.sendSuggestion(message: message))
    }

    func sendReport(message: String) async throws {
        try ensureSuccess(await settingRepo.sendReport(message: message))
    }

    private func ensureSuccess<T>(_ result: Result<BaseResponse<T>, APIError>) throws {
        switch result {
        case .success(let response):
            guard response.status == true else {
                throw APIError(type: .backend, message: response.message)
            }
        case .failure(let error):
            throw error
        }
    }
}
