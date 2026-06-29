//
//  PostDetailsViewCoverBadge.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewCoverBadge: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: "545454").opacity(0.7), in: Capsule())
    }
}
