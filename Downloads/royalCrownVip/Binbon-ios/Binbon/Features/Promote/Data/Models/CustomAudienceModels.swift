//
//  CustomAudienceModels.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import Foundation

// MARK: - Gender
enum AudienceGender: Int, CaseIterable, Identifiable, Codable {
    case all
    case female
    case male

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .all:    return "all".localized
        case .female: return "female".localized
        case .male:   return "male".localized
        }
    }
}

// MARK: - Custom Audience selection
struct CustomAudience: Codable, Equatable {
    var gender: AudienceGender = .all
    var ageRanges: Set<String> = []
    var interests: Set<String> = []
}
