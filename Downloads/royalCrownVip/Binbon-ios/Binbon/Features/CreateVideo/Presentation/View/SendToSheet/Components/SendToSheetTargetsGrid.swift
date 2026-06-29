//
//  SendToSheetTargetsGrid.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SendToSheetTargetsGrid: View {

    let items: [(String, String)]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        Image(systemName: item.0)
                            .font(.system(size: 20))
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(width: 50, height: 50)
                            .background(Color(hex: "E6E6EA"), in: Circle())
                        Text(item.1)
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: 64)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
