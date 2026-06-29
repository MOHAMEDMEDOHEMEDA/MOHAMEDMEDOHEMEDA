//
//  VideoFrameSelectorViewTopBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoFrameSelectorViewTopBar: View {

    let canSelect: Bool
    var onClose: () -> Void = {}
    var onDone: () -> Void = {}

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer()
            Text("post_edit_cover".localized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Button(action: onDone) {
                Text("done".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.buttonGradient, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(!canSelect)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
