//
//  CreateVideoViewTopBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewTopBar: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    @ObservedObject var effects: VideoEffectsState
    @Binding var showDurations: Bool
    @Binding var showLayouts: Bool
    let controlTint: Color
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.showPublish {
                    CreateVideoViewIconButton(systemName: "chevron.left", tint: controlTint) {
                        viewModel.showPublish = false
                        viewModel.capturedVideoURL = nil
                    }
                }
                CreateVideoViewIconButton(systemName: "xmark", tint: controlTint) { onClose() }
            }
            Spacer()
            CreateVideoViewControlRail(viewModel: viewModel,
                                       camera: camera,
                                       effects: effects,
                                       showDurations: $showDurations,
                                       showLayouts: $showLayouts,
                                       controlTint: controlTint)
        }
        .padding(.horizontal, 20)
    }
}
