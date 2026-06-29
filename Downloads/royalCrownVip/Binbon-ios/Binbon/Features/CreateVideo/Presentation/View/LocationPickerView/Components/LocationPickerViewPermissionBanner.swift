//
//  LocationPickerViewPermissionBanner.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct LocationPickerViewPermissionBanner: View {

    var onEnable: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Text("enable_location_hint".localized)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.appText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button(action: onEnable) {
                Text("enable".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.chromeButtonGradient, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: 10))
    }
}
