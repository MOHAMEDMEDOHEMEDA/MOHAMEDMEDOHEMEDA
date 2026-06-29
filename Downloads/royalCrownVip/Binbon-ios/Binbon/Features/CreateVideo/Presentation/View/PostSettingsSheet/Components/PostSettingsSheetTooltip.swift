//
//  PostSettingsSheetTooltip.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetTooltip: View {
    let height: CGFloat
    @Binding var showTip: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { showTip = false }

            VStack(spacing: 0) {
                Text("audience_tip".localized)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(14)
                    .frame(width: 214)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.92)))
                PostSettingsSheetDownTriangle()
                    .fill(Color.black.opacity(0.92))
                    .frame(width: 18, height: 10)
            }
            .padding(.top, height * 0.30)
            .onTapGesture { showTip = false }
        }
        .transition(.opacity)
    }
}
