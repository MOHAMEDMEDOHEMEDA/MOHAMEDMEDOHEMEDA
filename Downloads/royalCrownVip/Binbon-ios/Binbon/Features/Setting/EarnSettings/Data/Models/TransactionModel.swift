//
//  TransactionModel.swift
//  Binbon
//
//  Created by Husayn on 07/06/2026.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let coinAmount: String
    let price: String
    let date: String

    enum CodingKeys: String, CodingKey {
        case id
        case coinAmount = "coin_amount"
        case price
        case date
    }
}
