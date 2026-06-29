//
//  CommercialDisclosureCard.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureCard: View {

    @Binding var isDisclosed: Bool
    @Binding var selfBrand: Bool
    @Binding var sponsored: Bool

    private let cardBg = Color.themed(colored: Color(hex: "262626"),
                                      light: Color(hex: "F1F1F3"),
                                      dark: Color(hex: "262626"))

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("disclose_commercial_content".localized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.appText)
                    Text("disclose_commercial_content_sub".localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                DiscloseToggle(isOn: $isDisclosed)
                    .padding(.top, 2)
            }

            if isDisclosed {
                CommercialDisclosureCheckRow(title: "cd_your_brand_title".localized,
                                             subtitle: "cd_your_brand_sub".localized,
                                             isChecked: $selfBrand)
                    .padding(.top, 28)
                CommercialDisclosureCheckRow(title: "cd_branded_content_title".localized,
                                             subtitle: "cd_branded_content_sub".localized,
                                             isChecked: $sponsored)
                    .padding(.top, 22)
            }
        }
        .padding(16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 10))
    }
}
