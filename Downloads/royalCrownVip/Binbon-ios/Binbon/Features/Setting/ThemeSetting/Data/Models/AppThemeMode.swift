//
//  AppThemeMode.swift
//  Binbon
//
//  Created by Mrwan hany on 04/06/2026.
//

import Foundation

// MARK: - App Theme Mode
enum AppThemeMode: String, CaseIterable, Codable {
    case light
    case dark
    case system
    case colored
 

    var title: String {
        switch self {
        case .light:   "theme_light".localized
        case .dark:    "theme_dark".localized
        case .system:  "theme_system".localized
        case .colored: "theme_colored".localized
    
        }
    }
}
