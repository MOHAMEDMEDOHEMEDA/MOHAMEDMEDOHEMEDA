//
//  CommercialDisclosureSaveButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureSaveButton: View {

    var onSave: () -> Void = {}

    var body: some View {
        Button(action: onSave) {
            Text("save".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColor.chromeButtonGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
