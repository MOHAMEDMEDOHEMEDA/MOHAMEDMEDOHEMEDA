//
//  PostSettingsSheetRadioDot.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetRadioDot: View {
    let selected: Bool
    let accent: Color
    var body: some View {
        ZStack {
            Circle()
                .stroke(selected ? accent : Color.appText.opacity(0.5), lineWidth: 2)
                .frame(width: 20, height: 20)
            if selected {
                Circle().fill(accent).frame(width: 11, height: 11)
            }
        }
    }
}
