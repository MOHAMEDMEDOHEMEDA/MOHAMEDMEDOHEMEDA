//
//  PostDetailsViewShareIcons.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewShareIcons: View {

    var body: some View {
        HStack(spacing: 6) {
            PostDetailsViewShareIcon(name: "message.fill", color: Color(hex: "25D366"))
            PostDetailsViewShareIcon(name: "camera.fill", color: Color(hex: "C13584"))
            PostDetailsViewShareIcon(name: "paperplane.fill", color: Color(hex: "229ED9"))
            PostDetailsViewShareIcon(name: "link", color: Color.gray)
        }
    }
}
