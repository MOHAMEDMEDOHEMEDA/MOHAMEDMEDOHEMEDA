//
//  CommercialDisclosureHelpHeader.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureHelpHeader: View {

    var onClose: () -> Void = {}

    var body: some View {
        ZStack {
            Text("cd_help_nav_title".localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.appText)
            HStack {
                Button(action: onClose) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appText.opacity(0.15))
                .frame(height: 1)
        }
    }
}
