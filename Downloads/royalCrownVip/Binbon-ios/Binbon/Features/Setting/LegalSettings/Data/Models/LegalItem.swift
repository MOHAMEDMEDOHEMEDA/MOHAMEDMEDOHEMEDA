//
//  LegalItem.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import Foundation

struct LegalContent: Codable {
    let menu: [LegalMenuItem]?
    let termsAndConditions: LegalSectionContent?
    let privacyPolicy: LegalSectionContent?
    let intellectualPropertyRights: LegalSectionContent?
    let fairUsePolicy: LegalSectionContent?
    let dataDeletionRequest: LegalSectionContent?

    enum CodingKeys: String, CodingKey {
        case menu
        case termsAndConditions = "terms_and_conditions"
        case privacyPolicy = "privacy_policy"
        case fairUsePolicy = "fair_use_policy"
        case intellectualPropertyRights = "intellectual_property_rights"
        case dataDeletionRequest = "data_deletion_request"
    }
}
struct LegalMenuItem: Codable, Identifiable {
    var id: String { slug }

    let slug: String
    let title: String?
    let endpoint: String?
}

struct LegalSectionContent: Codable {
    let slug: String?
    let title: String?
    let sections: [LegalSection]?
}

struct LegalSection: Codable, Identifiable {
    let id: Int
    let title: String?
    let content: String?
}
