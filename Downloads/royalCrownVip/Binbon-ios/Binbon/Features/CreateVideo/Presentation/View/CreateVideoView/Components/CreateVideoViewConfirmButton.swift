//
//  CreateVideoViewConfirmButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewConfirmButton: View {

    let onConfirm: () -> Void

    var body: some View {
        Button(action: onConfirm) {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: "E14554"), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
