//
//  CreateVideoViewStoryAvatar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewStoryAvatar: View {

    let image: UIImage?

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: "3EFFF5")).frame(width: 26, height: 26)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
        }
    }
}
