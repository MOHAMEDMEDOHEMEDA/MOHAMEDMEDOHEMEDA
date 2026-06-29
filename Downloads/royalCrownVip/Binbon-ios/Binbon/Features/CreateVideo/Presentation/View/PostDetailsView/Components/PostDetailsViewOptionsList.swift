//
//  PostDetailsViewOptionsList.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewOptionsList: View {

    var onShowSettings: () -> Void = {}
    var onPrivacy: () -> Void = {}
    var onMoreOptions: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            PostDetailsViewDisclosureRow(icon: "plus", title: "post_add_link".localized)
            PostDetailsViewDisclosureRow(icon: "person.fill.badge.plus",
                                         title: "post_followers_can_view".localized,
                                         action: onShowSettings)
            PostDetailsViewDisclosureRow(icon: "lock.fill",
                                         title: "post_privacy_settings".localized,
                                         subtitle: "post_privacy_settings_subtitle".localized,
                                         action: onPrivacy)
            PostDetailsViewDisclosureRow(icon: "ellipsis", title: "post_more_options".localized,
                                         action: onMoreOptions)
            PostDetailsViewShareRow()
        }
    }
}
