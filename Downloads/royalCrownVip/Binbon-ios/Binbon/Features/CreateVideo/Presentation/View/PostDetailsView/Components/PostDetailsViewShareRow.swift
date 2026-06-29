//
//  PostDetailsViewShareRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewShareRow: View {

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .font(.system(size: 18))
                .foregroundStyle(.appText)
                .frame(width: 24, alignment: .center)
            Text("post_share_to".localized)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
            Spacer()
            PostDetailsViewShareIcons()
        }
    }
}
