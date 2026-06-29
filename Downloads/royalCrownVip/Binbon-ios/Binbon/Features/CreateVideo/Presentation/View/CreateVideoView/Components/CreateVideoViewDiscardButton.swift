//
//  CreateVideoViewDiscardButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewDiscardButton: View {

    let onDiscard: () -> Void

    var body: some View {
        Button(action: onDiscard) {
            Image(systemName: "delete.left")
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
