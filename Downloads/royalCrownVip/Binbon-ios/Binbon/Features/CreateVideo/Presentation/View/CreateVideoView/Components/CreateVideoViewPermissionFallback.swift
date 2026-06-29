//
//  CreateVideoViewPermissionFallback.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewPermissionFallback: View {

    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 12) {
                Image(systemName: "video.slash.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.5))
                Text("camera_access_needed".localized)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
