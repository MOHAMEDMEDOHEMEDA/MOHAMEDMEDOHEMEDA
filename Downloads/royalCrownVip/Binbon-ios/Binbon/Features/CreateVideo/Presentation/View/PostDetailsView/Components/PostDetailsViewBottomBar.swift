//
//  PostDetailsViewBottomBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewBottomBar: View {

    var onDrafts: () -> Void = {}
    var onPublish: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onDrafts) {
                HStack(spacing: 11) {
                    Image(systemName: "doc")
                        .font(.system(size: 18))
                    Text("drafts".localized)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: onPublish) {
                Text("publish".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 27)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}
