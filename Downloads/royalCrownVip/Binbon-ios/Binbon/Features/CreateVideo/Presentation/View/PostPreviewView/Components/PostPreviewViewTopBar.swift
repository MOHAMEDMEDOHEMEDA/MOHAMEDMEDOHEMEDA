//
//  PostPreviewViewTopBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostPreviewViewTopBar: View {

    let railIcons: [String]
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                PostPreviewViewIcon(systemName: "chevron.backward") { onClose() }
                PostPreviewViewIcon(systemName: "xmark") { onClose() }
            }
            Spacer()
            VStack(spacing: 6) {
                ForEach(railIcons, id: \.self) { name in
                    PostPreviewViewIcon(systemName: name) {}
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
