//
//  CreateVideoViewFilterCarousel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewFilterCarousel: View {

    @ObservedObject var effects: VideoEffectsState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(VideoFilter.allCases) { filter in
                    let selected = effects.filter == filter
                    Button { effects.filter = filter } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(swatch(filter))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Circle().stroke(.white, lineWidth: selected ? 2.5 : 0)
                                )
                                .overlay(
                                    Circle().stroke(.white.opacity(0.4), lineWidth: 1)
                                )
                            Text(filter.titleKey.localized)
                                .font(.system(size: 11, weight: selected ? .semibold : .regular))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func swatch(_ filter: VideoFilter) -> Color {
        filter.overlay?.color ?? Color(hex: "BDBDBD")
    }
}
