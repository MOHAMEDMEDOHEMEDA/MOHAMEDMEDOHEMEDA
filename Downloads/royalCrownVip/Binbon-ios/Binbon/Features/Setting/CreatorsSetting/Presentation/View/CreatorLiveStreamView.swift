//
//  CreatorLiveStreamView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorLiveStreamView: View {

    @StateObject private var viewModel = LiveStreamSettingsViewModel()

    var body: some View {
        LiveStreamControlsList(viewModel: viewModel)
    }
}

#Preview {
    CreatorLiveStreamView()
        .padding()
}
