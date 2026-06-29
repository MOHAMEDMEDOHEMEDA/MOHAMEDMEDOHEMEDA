//
//  VIPSubviews.swift
//  Binbon
//
//  Created by Aya Mashaly on 06/06/2026.
//

import SwiftUI

struct VIPRow: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(nil)

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.secondaryTextColor)
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

/// Shared "VIP / buy VIP levels" body — currently a single navigation row.
/// Used by InteractionSetting and the Creators "VIP Creator mode" section.
struct VIPControlsList: View {
    var onMembershipLevelTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 12) {
            VIPRow(title: "set_vip_membership_level".localized,
                   action: onMembershipLevelTap)
        }
    }
}
