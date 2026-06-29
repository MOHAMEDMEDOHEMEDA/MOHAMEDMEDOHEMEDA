//
//  LocationPickerViewTopBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct LocationPickerViewTopBar: View {

    var onClose: () -> Void = {}

    var body: some View {
        ZStack {
            Text("add_location".localized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.appText)
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.top, 8)
    }
}
