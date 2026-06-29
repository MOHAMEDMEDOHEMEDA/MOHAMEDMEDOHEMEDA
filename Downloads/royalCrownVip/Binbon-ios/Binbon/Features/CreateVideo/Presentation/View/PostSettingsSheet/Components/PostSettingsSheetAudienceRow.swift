//
//  PostSettingsSheetAudienceRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetAudienceRow: View {
    let value: PostSettingsSheet.Audience
    let title: String
    var subtitle: String? = nil
    var hasChevron: Bool = false
    var onOpen: (() -> Void)? = nil
    @Binding var audience: PostSettingsSheet.Audience

    private let accent = Color(hex: "E14554")

    var body: some View {
        Button { audience = value; onOpen?() } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.system(size: 14))
                            .foregroundStyle(.appText)
                        if hasChevron {
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.appText.opacity(0.7))
                        }
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                }
                Spacer()
                PostSettingsSheetRadioDot(selected: audience == value, accent: accent)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
