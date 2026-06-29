//
//  PostDetailsViewChevron.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewChevron: View {

    var body: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.appText.opacity(0.8))
    }
}
