//
//  CommercialDisclosureHelpView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureHelpView: View {

    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 0) {
            CommercialDisclosureHelpHeader(onClose: onClose)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 22) {
                    CommercialDisclosureHelpIllustration()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                    Text("cd_help_title".localized)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.appText)
                        .fixedSize(horizontal: false, vertical: true)

                    CommercialDisclosureHelpSection(title: "cd_help_why_title".localized,
                                                    text: "cd_help_why_body".localized)
                    CommercialDisclosureHelpSection(title: "cd_help_when_title".localized,
                                                    text: "cd_help_when_body".localized)
                    CommercialDisclosureHelpSection(title: "cd_help_how_title".localized,
                                                    text: "cd_help_how_body".localized)
                    CommercialDisclosureHelpSection(title: "cd_help_policy_title".localized,
                                                    text: "cd_help_policy_body".localized)
                    CommercialDisclosureHelpSection(title: "cd_help_ads_title".localized,
                                                    text: "cd_help_ads_body".localized)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .adaptiveContentWidth()
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
    }
}
