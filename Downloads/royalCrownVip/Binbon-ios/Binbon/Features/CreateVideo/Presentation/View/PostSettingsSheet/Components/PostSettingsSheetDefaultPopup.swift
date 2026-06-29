//
//  PostSettingsSheetDefaultPopup.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct PostSettingsSheetDefaultPopup: View {

    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
    }
}
