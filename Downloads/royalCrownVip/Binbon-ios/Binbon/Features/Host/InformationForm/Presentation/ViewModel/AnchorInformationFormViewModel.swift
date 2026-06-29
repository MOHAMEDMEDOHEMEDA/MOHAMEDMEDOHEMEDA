//
//  AnchorInformationFormViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class AnchorInformationFormViewModel: ObservableObject {

    // TODO: Mock state — wire to a Repo/Service once the host-registration
    // endpoint exists.
    @Published var gender: GenderType = .male
    @Published var age: Int? = nil
    @Published var phoneCountry: Country? = nil
    @Published var phoneNumber: String = ""
    @Published var anchorCountry: Country? = nil
    @Published var nationalId: String = ""
    @Published var idCopyImage: UIImage? = nil
    @Published var anchorPhoto1: UIImage? = nil
    @Published var anchorPhoto2: UIImage? = nil

    let ageRange = Array(18...80)
}
