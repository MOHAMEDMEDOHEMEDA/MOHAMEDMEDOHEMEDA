//
//  MarketSettingViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI
import Combine


@MainActor
class MarketSettingViewModel: ObservableObject {
    
    @Published var isPrivateAccount: Bool = false
    @Published var isPublicAccount: Bool = false
    @Published var acceptFriendRequestsWhenPrivate: Bool = false
}
