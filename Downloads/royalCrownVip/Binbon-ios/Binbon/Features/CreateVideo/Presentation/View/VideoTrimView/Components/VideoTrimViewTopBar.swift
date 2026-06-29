//
//  VideoTrimViewTopBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewTopBar: View {
    let isProcessing: Bool
    let onClose: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            Spacer()
            Button(action: onNext) {
                Text("next".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 66)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
