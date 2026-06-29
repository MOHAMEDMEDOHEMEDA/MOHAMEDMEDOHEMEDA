//
//  SocialProvider.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//



import Foundation

// MARK: - SocialRequest
struct SocialRequest: Codable {
    
    var accessToken: String?
    var deviceType: String?
    var operatingSystem: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case deviceType = "device_type"
        case operatingSystem = "operating_system"
    }
}

// MARK: - SocialProvider
enum SocialProvider: String, Identifiable, CaseIterable {
    case accountVerification
    case google
    case apple
    case tikTok
    case instagram
    case x
    case facebook
    case snapchat
    case threads
    
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .accountVerification: "Account Verification"
        default: rawValue.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .accountVerification: "Reg_Verify"
        case .google: "Reg_Google"
        case .apple: "Reg_Apple"
        case .tikTok: "Reg_TikTok"
        case .instagram:  "Reg_Instagram"
        case .x: "Reg_X"
        case .facebook: "Reg_Facebook"
        case .snapchat: "Reg_Snapchat"
        case .threads: "Reg_Threads"
        }
    }
}
