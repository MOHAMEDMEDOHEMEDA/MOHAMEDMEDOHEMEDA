//
//  PostSettingsSheetToggleRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PostSettingsSheetTextBlock(title: title, subtitle: subtitle)
            Spacer()
            PostSettingsSheetMiniToggle(isOn: $isOn)
                .padding(.top, 2)
        }
    }
}
