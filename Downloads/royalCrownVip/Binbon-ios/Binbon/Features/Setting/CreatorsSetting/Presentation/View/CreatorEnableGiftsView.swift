//
//  CreatorEnableGiftsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorEnableGiftsView: View {

    @StateObject private var viewModel = CreatorEnableGiftsViewModel()

    var body: some View {
        Toggle(isOn: $viewModel.giftsEnabled) {
            Text("gifts_toggle_title".localized)
                .font(.footnote.weight(.semibold))
                .lineLimit(nil)
        }
        .tint(.green)
    }
}
