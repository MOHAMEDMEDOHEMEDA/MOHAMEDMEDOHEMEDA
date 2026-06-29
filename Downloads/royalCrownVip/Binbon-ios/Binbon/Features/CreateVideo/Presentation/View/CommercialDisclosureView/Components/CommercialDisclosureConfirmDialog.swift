//
//  CommercialDisclosureConfirmDialog.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureConfirmDialog: View {

    var image: Image? = nil
    let title: String
    let message: String
    let leftTitle: String
    let rightTitle: String
    var onLeft: () -> Void = {}
    var onRight: () -> Void = {}

    private let cardBg = Color.themed(colored: Color(hex: "262626"),
                                      light: Color(hex: "F1F1F3"),
                                      dark: Color(hex: "262626"))
    private let hairline = Color.appText.opacity(0.25)

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    if let image {
                        image
                            .font(.system(size: 34))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.appText)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(.appText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Rectangle()
                    .fill(hairline)
                    .frame(height: 1)

                HStack(spacing: 0) {
                    dialogButton(leftTitle, action: onLeft)
                    Rectangle()
                        .fill(hairline)
                        .frame(width: 1)
                    dialogButton(rightTitle, action: onRight)
                }
                .frame(height: 47)
            }
            .frame(width: 248)
            .background(cardBg, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    private func dialogButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
