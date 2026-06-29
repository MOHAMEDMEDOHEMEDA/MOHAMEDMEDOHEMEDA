//
//  AnchorAuthorizationView.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct AnchorAuthorizationView: View {

    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("anchor_intro_title".localized)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.appText)

                    Text("anchor_how_title".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.appText)
                    Text("anchor_how_body".localized)
                        .font(.system(size: 13))
                        .foregroundStyle(.appText.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("anchor_examples_title".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.appText)
                    HStack(spacing: 0) {
                        Text("anchor_product_link".localized)
                            .frame(maxWidth: .infinity)
                        Text("anchor_app_download".localized)
                            .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.8))
                    Image("anchor-examples")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .adaptiveContentWidth()
            .appBackground()
            .appNavigation(title: "cd_anchor_authorization".localized)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appText)
                    }
                }
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
    }
}
