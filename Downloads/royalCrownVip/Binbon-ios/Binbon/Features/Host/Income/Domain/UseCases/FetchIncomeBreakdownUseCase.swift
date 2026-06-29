//
//  FetchIncomeBreakdownUseCase.swift
//  Binbon
//
//  Domain layer — loads the per-category earnings breakdown.
//

import Foundation

struct FetchIncomeBreakdownUseCase {
    private let repository: IncomeRepositoryProtocol

    init(repository: IncomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [IncomeCategory] {
        try await repository.fetchBreakdown()
    }
}
