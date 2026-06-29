//
//  CoinPackage.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import Foundation

/// A purchasable coin/gold package shown in the recharge grid.
struct CoinPackage: Identifiable {
    let id = UUID()
    let amount: Int
    let price: String   // pre-formatted, e.g. "CHF 0.50"
}
