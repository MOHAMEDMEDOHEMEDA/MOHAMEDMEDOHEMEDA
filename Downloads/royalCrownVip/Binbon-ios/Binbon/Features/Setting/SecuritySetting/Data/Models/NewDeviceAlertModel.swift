//
//  NewDeviceAlertModel.swift
//  Binbon
//
//  Created by Salah Khaled on 08/06/2026.
//

import Foundation

/// A single new-device sign-in alert shown in the security settings.
/// Currently presentational — fed sample data until the alerts endpoint exists.
struct NewDeviceAlert {
    let timeAgo: String
    let location: String
    let device: String

    static let sample = NewDeviceAlert(
        timeAgo: "1 hour ago",
        location: "Near Aleppo, Syria",
        device: "Binbon for Android"
    )
}
