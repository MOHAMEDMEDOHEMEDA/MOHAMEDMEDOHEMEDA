//
//  HelpAndSupportRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — help & support boundary. Returns entities and throws `APIError`.
//

import Foundation

protocol HelpAndSupportRepositoryProtocol {
    func fetchSupportFaqs() async throws -> [SupportFAQ]
    func sendSuggestion(message: String) async throws
    func sendReport(message: String) async throws
}
