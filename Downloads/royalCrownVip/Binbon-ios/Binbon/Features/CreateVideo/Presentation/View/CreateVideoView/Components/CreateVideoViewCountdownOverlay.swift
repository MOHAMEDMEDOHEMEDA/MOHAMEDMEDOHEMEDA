//
//  CreateVideoViewCountdownOverlay.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewCountdownOverlay: View {

    let value: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            Text("\(value)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 12)
                .id(value)
                .transition(.scale.combined(with: .opacity))
        }
        .allowsHitTesting(false)
    }
}
