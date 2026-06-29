//
//  VideoTrimViewSelectedLabel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewSelectedLabel: View {
    let selectedSeconds: Double

    var body: some View {
        Text("selected_seconds".localizedFormat(String(format: "%.1f", selectedSeconds)))
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
