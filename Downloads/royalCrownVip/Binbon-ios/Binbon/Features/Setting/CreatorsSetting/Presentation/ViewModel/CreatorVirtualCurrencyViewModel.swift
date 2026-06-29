//
//  CreatorVirtualCurrencyViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 08/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorVirtualCurrencyViewModel: ObservableObject {
    @Published var currentWealth: Int = 989_865_984

    @Published var spending: [CreatorSpendingPeriod] = [
        CreatorSpendingPeriod(title: "creator_spending_daily".localized,
                              amount: 9_998,
                              icon: "tabler_coin-filled"),
        CreatorSpendingPeriod(title: "creator_spending_weekly".localized,
                              amount: 567_989,
                              icon: "tdesign_money"),
        CreatorSpendingPeriod(title: "creator_spending_monthly".localized,
                              amount: 789_988_779,
                              icon: "material-symbols_money-bag")
    ]

    @Published var gifts: [CreatorGift] = [
        CreatorGift(name: "Gift 1", price: 5_000, imageName: "Gift"),
        CreatorGift(name: "Gift 2", price: 5_000, imageName: "Gift"),
        CreatorGift(name: "Gift 1", price: 5_000, imageName: "Gift"),
    ]
}
