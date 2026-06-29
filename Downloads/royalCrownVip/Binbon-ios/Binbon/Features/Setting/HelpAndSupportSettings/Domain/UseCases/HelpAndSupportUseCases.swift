//
//  HelpAndSupportUseCases.swift
//  Binbon
//
//  Domain layer — help & support use cases.
//

import Foundation

struct FetchSupportFaqsUseCase {
    private let repository: HelpAndSupportRepositoryProtocol
    init(repository: HelpAndSupportRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [SupportFAQ] {
        try await repository.fetchSupportFaqs()
    }
}

struct SendSuggestionUseCase {
    private let repository: HelpAndSupportRepositoryProtocol
    init(repository: HelpAndSupportRepositoryProtocol) { self.repository = repository }
    func execute(message: String) async throws {
        try await repository.sendSuggestion(message: message)
    }
}

struct SendSupportReportUseCase {
    private let repository: HelpAndSupportRepositoryProtocol
    init(repository: HelpAndSupportRepositoryProtocol) { self.repository = repository }
    func execute(message: String) async throws {
        try await repository.sendReport(message: message)
    }
}
