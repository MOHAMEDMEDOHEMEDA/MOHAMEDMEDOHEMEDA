//
//  CreatorEnableGiftsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorEnableGiftsViewModel: ObservableObject {
    @Published var giftsEnabled: Bool = true
}
