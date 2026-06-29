//
//  NotifBadge.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifBadge: View {
    let text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.appText)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(color, in: RoundedRectangle(cornerRadius: 5))
    }
}
