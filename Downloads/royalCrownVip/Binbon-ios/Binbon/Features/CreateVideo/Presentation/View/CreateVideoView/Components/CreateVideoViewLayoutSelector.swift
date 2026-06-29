//
//  CreateVideoViewLayoutSelector.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewLayoutSelector: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    let controlTint: Color
    let chipBackground: Color

    var body: some View {
        HStack(spacing: 10) {
            ForEach(VideoLayoutOption.allCases) { option in
                let selected = viewModel.layout == option
                Button { viewModel.select(option) } label: {
                    Image(systemName: option.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(controlTint)
                        .frame(width: 44, height: 44)
                        .background(chipBackground, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(.white, lineWidth: selected ? 2 : 0)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
