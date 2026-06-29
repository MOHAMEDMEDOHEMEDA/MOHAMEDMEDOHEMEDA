//
//  FriendReportReasonsView.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 17/06/2026.

//

import SwiftUI

struct FriendReportReasonsView: View {

    let friend: FriendItem

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedReason: FriendReportReason?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 3) {
                ForEach(FriendReportReason.reportsReasons) { reason in
                    FriendReportReasonRow(title: reason.titleKey.localized) {
                        selectedReason = reason
                    }

                    if reason.id != FriendReportReason.reportsReasons.last?.id {
                        divider
                    }
                }
            }
            .padding(.top, 8)
            .adaptiveContentWidth()
        }
        .orangeBottomGradientBackground()
        .appNavigation(title: "select_a_reason".localized)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedReason) { reason in
            FriendReportDetailsView(friend: friend, reason: reason)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                .accessibilityLabel("close".localized)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(theme.preferredColorScheme)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appText.opacity(0.18))
            .frame(height: 1)
            .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        FriendReportReasonsView(friend: .samples[0])
    }
}
