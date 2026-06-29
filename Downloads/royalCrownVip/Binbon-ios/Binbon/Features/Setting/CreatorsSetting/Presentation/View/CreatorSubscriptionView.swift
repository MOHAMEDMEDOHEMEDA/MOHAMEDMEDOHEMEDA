//
//  CreatorSubscriptionView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorSubscriptionView: View {

    @StateObject private var viewModel = CreatorSubscriptionViewModel()

    var body: some View {
        SubscriptionContentList(
            subscriptions: viewModel.subscriptions,
            onRenew: viewModel.renew,
            onCancel: viewModel.cancel
        )
    }
}

#Preview {
    CreatorSubscriptionView()
        .padding()
}
