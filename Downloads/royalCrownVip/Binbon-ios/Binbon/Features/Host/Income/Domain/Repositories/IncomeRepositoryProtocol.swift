//
//  IncomeRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — earnings boundary the use cases depend on. Returns entities
//  and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol IncomeRepositoryProtocol {
    /// The per-category earnings breakdown shown in the income legend.
    func fetchBreakdown() async throws -> [IncomeCategory]
}
