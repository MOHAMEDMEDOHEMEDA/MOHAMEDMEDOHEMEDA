//
//  NotifCheckbox.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifCheckbox: View {
    let isOn: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .stroke(.appText, lineWidth: 1.5)
            .frame(width: 18, height: 18)
            .overlay {
                if isOn {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.green)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.appText)
                        )
                }
            }
    }
}
