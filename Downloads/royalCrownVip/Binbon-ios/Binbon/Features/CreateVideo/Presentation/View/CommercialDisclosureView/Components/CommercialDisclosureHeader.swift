//
//  CommercialDisclosureHeader.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureHeader: View {

    var onClose: () -> Void = {}
    var onHelp: () -> Void = {}

    var body: some View {
        ZStack {
            Text("commercial_disclosure".localized)
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
                Button(action: onHelp) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(.appText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}
