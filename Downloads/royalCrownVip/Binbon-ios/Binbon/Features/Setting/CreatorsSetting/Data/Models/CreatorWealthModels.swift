//
//  CreatorWealthModels.swift
//  Binbon
//
//  Created by Ramez Hamdy on 08/06/2026.
//

import Foundation

// MARK: - Gift
struct CreatorGift: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let imageName: String?
}

// MARK: - Spending period
struct CreatorSpendingPeriod: Identifiable {
    let id = UUID()
    let title: String
    let amount: Int
    let icon: String
}
