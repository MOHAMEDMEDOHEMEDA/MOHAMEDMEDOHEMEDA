//
//  IncomeRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for earnings. Mock-backed during the current
//  pre-integration phase.
//

import SwiftUI

protocol IncomeRemoteDataSource {
    func fetchBreakdown() async throws -> [IncomeCategory]
}

// MARK: - Mock

struct MockIncomeRemoteDataSource: IncomeRemoteDataSource {

    func fetchBreakdown() async throws -> [IncomeCategory] {
        IncomeCategory.mock
    }
}

private extension IncomeCategory {
    static let mock: [IncomeCategory] = [
        IncomeCategory(titleKey: "live_broadcast",     amount: 0, color: Color(hex: "4CD964")),
        IncomeCategory(titleKey: "family_gift",        amount: 0, color: Color(hex: "FBBC05")),
        IncomeCategory(titleKey: "silver_coins_gift",  amount: 0, color: Color(hex: "0498FA")),
        IncomeCategory(titleKey: "chat",               amount: 0, color: Color(hex: "EA00FF")),
        IncomeCategory(titleKey: "guardian_angel",     amount: 0, color: Color(hex: "FDF903")),
        IncomeCategory(titleKey: "shared_broadcast",   amount: 0, color: Color(hex: "FF6050")),
        IncomeCategory(titleKey: "reward",             amount: 0, color: Color(hex: "3EFFF5")),
        IncomeCategory(titleKey: "super_winner",       amount: 0, color: Color(hex: "7C0930")),
        IncomeCategory(titleKey: "vote",               amount: 0, color: Color(hex: "F44E90"))
    ]
}
