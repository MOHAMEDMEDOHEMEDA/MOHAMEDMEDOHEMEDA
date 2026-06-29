//
//  SendToSheetHeader.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SendToSheetHeader: View {

    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text("send_to".localized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}
