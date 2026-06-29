//
//  NotifToggleRow.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .foregroundStyle(.appText)
                .font(.subheadline.weight(.semibold))
        }
        .toggleStyle(NotifSwitchStyle())
    }
}
