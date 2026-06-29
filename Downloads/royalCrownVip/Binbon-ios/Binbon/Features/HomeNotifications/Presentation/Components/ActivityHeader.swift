//
//  ActivityHeader.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityHeader: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Text("activity".localized)
                .font(.headline.weight(.bold))
                .foregroundStyle(.appText)

            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}
