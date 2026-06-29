//
//  PostDetailsViewMergeChip.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewMergeChip: View {

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "play.fill")
                .font(.system(size: 10))
            Text("Elin")
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(.appText)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 4))
    }
}
