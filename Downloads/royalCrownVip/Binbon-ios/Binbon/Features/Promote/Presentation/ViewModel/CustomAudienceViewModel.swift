//
//  CustomAudienceViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import UIKit
import Combine

@MainActor
final class CustomAudienceViewModel: ObservableObject {

    // MARK: - Properties
    @Published var gender: AudienceGender = .all
    @Published var selectedAges: Set<String> = []
    @Published var selectedInterests: Set<String> = []

    @Published var error: APIError?
    @Published var isLoading: Bool = false

    let ageOptions: [String] = [
        "13-17", "18-24", "25-34", "35-44", "45-54", "55+"
    ]

    let interestOptions: [String] = [
        "interest_education", "interest_vehicles_transportation", "interest_baby_kids_maternity",
        "interest_beauty_personal_care", "interest_tech_electronics", "interest_appliances",
        "interest_travel", "interest_household_products", "interest_pets", "interest_apps",
        "interest_home_improvement", "interest_apparel_accessories", "interest_news_entertainment",
        "interest_business_services", "interest_games", "interest_life_services",
        "interest_food_beverage", "interest_sports_outdoors", "interest_ecommerce_nonapp"
    ]

    // MARK: - Derived state
    var isAllAges: Bool { selectedAges.isEmpty }
    var isAllInterests: Bool { selectedInterests.isEmpty }

    // MARK: - Init
    init(audience: CustomAudience) {
        gender = audience.gender
        selectedAges = audience.ageRanges
        selectedInterests = audience.interests
    }

    // MARK: - Actions
    func selectGender(_ gender: AudienceGender) {
        self.gender = gender
    }

    func selectAllAges() {
        selectedAges.removeAll()
    }

    func toggleAge(_ age: String) {
        if selectedAges.contains(age) {
            selectedAges.remove(age)
        } else {
            selectedAges.insert(age)
        }
    }

    func selectAllInterests() {
        selectedInterests.removeAll()
    }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    var audience: CustomAudience {
        CustomAudience(
            gender: gender,
            ageRanges: selectedAges,
            interests: selectedInterests
        )
    }

    func save() {
        // TODO: Replace with API call / hand the audience back to the caller.
    }
}
