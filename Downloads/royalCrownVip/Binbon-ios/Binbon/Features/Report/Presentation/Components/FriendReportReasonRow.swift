//
//  FriendReportReasonRow.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 17/06/2026.
//

import SwiftUI

// MARK: - Row

 struct FriendReportReasonRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    

                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.appText)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    FriendReportReasonRow(title: "Spam", action: {
        //
    })
}
