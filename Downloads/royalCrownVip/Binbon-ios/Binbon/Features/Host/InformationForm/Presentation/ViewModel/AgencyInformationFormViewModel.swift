//
//  AgencyInformationFormViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class AgencyInformationFormViewModel: ObservableObject {

    // TODO: Mock state — wire to a Repo/Service once the agency-registration
    // endpoint exists.
    @Published var isHostVoice: Bool = false
    @Published var agencyCode: String = ""
    @Published var agencyName: String = ""
    @Published var brokerId: String = ""
    @Published var micoId: String = ""

    @Published var gender: GenderType = .male
    @Published var age: Int? = nil
    @Published var phoneCountry: Country? = nil
    @Published var phoneNumber: String = ""
    @Published var anchorCountry: Country? = nil
    @Published var nationalId: String = ""

    let ageRange = Array(18...80)
}
