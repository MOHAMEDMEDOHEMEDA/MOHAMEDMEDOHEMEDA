//
//  PrivacySettingEnum.swift
//  Binbon
//
//  Created by Salah Khaled on 22/05/2026.
//

import Foundation

enum PrivacySettingEnum: Int, DynamicOptionProtocol {
    case everyone = 0
    case friends = 1
    case mutualFriends = 2
    case nobody = 3
    
    var title: String {
        switch self {
        case .everyone: "Everyone"
        case .friends: "Friends"
        case .mutualFriends: "Mutual Friends"
        case .nobody: "Nobody"
        }
    }
}

enum ProfilePrivacyEnum: Int, DynamicOptionProtocol {
    case everyone = 0
    case friends = 1
    case nobody = 3
    
    var title: String {
        switch self {
        case .everyone: "Everyone"
        case .friends: "Friends"
        case .nobody: "Nobody"
        }
    }
}

enum FriendPrivacyEnum: Int, DynamicOptionProtocol {
    case everyone = 0
    case mutualFriends = 2
    
    var title: String {
        switch self {
        case .everyone: "Everyone"
        case .mutualFriends: "Mutual Friends"
        }
    }
}
