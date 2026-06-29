//
//  NotificationSettingModel.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import Foundation

// MARK: - Time group (section headers inside a feed)
enum NotifGroup: String {
    case today
    case yesterday
    case last7Days
    case previously

    var localized: String {
        switch self {
        case .today: return "group_today".localized
        case .yesterday: return "group_yesterday".localized
        case .last7Days: return "group_last_7_days".localized
        case .previously: return "group_previously".localized
        }
    }
}
