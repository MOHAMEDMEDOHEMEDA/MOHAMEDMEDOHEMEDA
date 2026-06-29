//
//  PromotePostCard.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromotePostCard: View {
    let post: PromotePost

    var body: some View {
        HStack(spacing: 10) {
            ImageView(
                post.imageURL,
                placeholder: Image(systemName: "photo")
            )
            .frame(width: 49, height: 49)
            .clipShape(RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading, spacing: 6) {
                Text(post.caption)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)

                Text("posted_on".localized + " \(post.postedDate)")
                    .font(.caption2)
            }

            Spacer(minLength: 0)
        }
    }
}
