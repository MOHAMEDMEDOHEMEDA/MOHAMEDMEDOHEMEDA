//
//  CreatorSubscriptionViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorSubscriptionViewModel: ObservableObject {

    @Published var subscriptions: [SubscriptionItem] = [
        SubscriptionItem(clubName: "نادي Shady Nabil",            price: "5.89 $ / شهر"),
        SubscriptionItem(clubName: "نادي Salma Nabil",            price: "5.89 $ / شهر"),
        SubscriptionItem(clubName: "معجب مميز بنادي Saif gamer",   price: "9.89 $ / شهر")
    ]

    func renew(_ item: SubscriptionItem) {
        // TODO: wire to renewal flow
    }

    func cancel(_ item: SubscriptionItem) {
        subscriptions.removeAll { $0.id == item.id }
    }
}
