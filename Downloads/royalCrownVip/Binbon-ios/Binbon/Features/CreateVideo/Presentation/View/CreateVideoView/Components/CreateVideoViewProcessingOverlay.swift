//
//  CreateVideoViewProcessingOverlay.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewProcessingOverlay: View {

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
        .transition(.opacity)
    }
}
