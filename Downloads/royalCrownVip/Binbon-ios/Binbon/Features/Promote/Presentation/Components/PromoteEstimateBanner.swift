//
//  PromoteEstimateBanner.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteEstimateBanner: View {
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))

            Text(caption)
                .font(.system(size: 14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(height: 62)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColor.promoteEstimateBannerFill)
        )
    }
}

#Preview {
    PromoteEstimateBanner(
        value: "29,691 - 1,161,668",
        caption: "Estimated profile views"
    )
    .padding()
    .background(LinearGradient(colors: [Color(hex: "FFABB3"), Color(hex: "B671A6")], startPoint: .leading, endPoint: .trailing))
}
