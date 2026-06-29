//
//  ReasonBannerView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI

struct ReasonBannerView: View {

    let reason: String
    var reasonDescription: String? = nil
    var bullets: [String]? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: "report_reason_format".localized, reason.localized))
                .font(.system(size: 16, weight: .medium))

            if let reasonDescription {
                Text(reasonDescription.localized)
                    .font(.system(size: 14, weight: .regular))
            }

            if let bullets {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { item in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(item.localized)
                        }
                    }
                }
                .font(.system(size: 14, weight: .regular))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(AppColor.backgroundGradient)
    }
}
