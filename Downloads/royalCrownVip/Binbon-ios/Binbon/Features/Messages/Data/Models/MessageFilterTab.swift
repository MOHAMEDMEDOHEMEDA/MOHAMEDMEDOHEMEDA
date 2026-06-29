//
//  MessageFilterTab.swift
//  Binbon
//
//  The relationship filters shown as folder tabs above the Messages list
//  (أصدقائي / أتابعهم / يتابعني …). UI-only for now — selecting one is a no-op
//  beyond highlighting until the messaging API can filter conversations.
//

import Foundation

enum MessageFilterTab: String, CaseIterable, Identifiable {
    case friends
    case iFollow
    case followsMe
    case strangers
    case management
    case family
    case agency
    case agent
    case groups
    case favorites

    var id: String { rawValue }

    /// Localization key for the tab label (present in both en/ar tables).
    var titleKey: String {
        switch self {
        case .friends:    return "messages_tab_friends"
        case .iFollow:    return "messages_tab_i_follow"
        case .followsMe:  return "messages_tab_follows_me"
        case .strangers:  return "messages_tab_strangers"
        case .management: return "messages_tab_management"
        case .family:     return "messages_tab_family"
        case .agency:     return "messages_tab_agency"
        case .agent:      return "messages_tab_agent"
        case .groups:     return "messages_tab_groups"
        case .favorites:  return "messages_tab_favorites"
        }
    }
}
