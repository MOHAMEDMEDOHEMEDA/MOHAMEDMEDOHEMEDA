//
//  CreateVideoViewFrontFlashOverlay.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewFrontFlashOverlay: View {

    var body: some View {
        Color.white
            .opacity(0.92)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .transition(.opacity)
    }
}
