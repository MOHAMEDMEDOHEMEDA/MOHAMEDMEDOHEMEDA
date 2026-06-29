//
//  SecuritySettingModel.swift
//  Binbon
//
//  Created by Salah Khaled on 24/05/2026.
//

import Foundation

struct SecuritySettingResponse: Codable {
    
    let twoFactorEnabled: Bool?
    let twoFactorChannel: String?
    let biometricEnabled: Bool?
    let biometricType: String?
    let biometricMethods: [String]?
    let newDeviceAlertsEnabled: Bool?
    let recoveryCodesCount: Int?

    enum CodingKeys: String, CodingKey {
        
        case twoFactorEnabled = "two_factor_enabled"
        case twoFactorChannel = "two_factor_channel"
        case biometricEnabled = "biometric_enabled"
        case biometricType = "biometric_type"
        case biometricMethods = "biometric_methods"
        case newDeviceAlertsEnabled = "new_device_alerts_enabled"
        case recoveryCodesCount = "recovery_codes_count"
    }
}

// MARK: - Biometric Update Request
struct BiometricUpdateRequest: Encodable {

    let enabled: Bool
    let deviceSupported: Bool
    let biometricType: String

    enum CodingKeys: String, CodingKey {
        case enabled
        case deviceSupported = "device_supported"
        case biometricType = "biometric_type"
    }
}
