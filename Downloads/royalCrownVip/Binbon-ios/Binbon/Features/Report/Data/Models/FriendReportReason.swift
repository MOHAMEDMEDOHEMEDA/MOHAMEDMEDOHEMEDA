//
//  FriendReportReason.swift
//  Binbon
//
//  Flat report-reason list shown when reporting a friend from the Friends tab.
//

import Foundation

struct FriendReportReason: Identifiable, Hashable {
    var id: String { titleKey }
    let titleKey: String
    let descriptionKey: String

    static let reportsReasons: [FriendReportReason] = [
        .init(titleKey: "friend_report_reason_spam", descriptionKey: "friend_report_desc_spam"),
        .init(titleKey: "friend_report_reason_harassment", descriptionKey: "friend_report_desc_harassment"),
        .init(titleKey: "friend_report_reason_hate_speech", descriptionKey: "friend_report_desc_hate_speech"),
        .init(titleKey: "friend_report_reason_violence", descriptionKey: "friend_report_desc_violence"),
        .init(titleKey: "friend_report_reason_nudity", descriptionKey: "friend_report_desc_nudity"),
        .init(titleKey: "friend_report_reason_scam", descriptionKey: "friend_report_desc_scam"),
        .init(titleKey: "friend_report_reason_false_info", descriptionKey: "friend_report_desc_false_info"),
        .init(titleKey: "friend_report_reason_child_safety", descriptionKey: "friend_report_desc_child_safety"),
        .init(titleKey: "friend_report_reason_copyright", descriptionKey: "friend_report_desc_copyright"),
        .init(titleKey: "friend_report_reason_other", descriptionKey: "friend_report_desc_other"),
    ]
}
