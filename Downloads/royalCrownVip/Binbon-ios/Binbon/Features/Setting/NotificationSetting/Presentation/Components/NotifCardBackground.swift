//
//  NotifCardBackground.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

extension View {
   
    func notifCardBackground() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                // Per-theme section surface: solid charcoal on Dark
                // (matches the design), translucent ink on Light / Colored.
                AppColor.sectionSurface,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
    }
}
