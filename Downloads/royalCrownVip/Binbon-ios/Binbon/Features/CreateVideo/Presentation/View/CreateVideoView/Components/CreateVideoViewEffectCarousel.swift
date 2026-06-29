//
//  CreateVideoViewEffectCarousel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewEffectCarousel: View {

    @ObservedObject var effects: VideoEffectsState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(VideoEffect.allCases) { effect in
                    let selected = effects.effect == effect
                    Button { effects.effect = effect } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(selected ? AnyShapeStyle(AppColor.buttonGradient)
                                                   : AnyShapeStyle(Color.white.opacity(0.15)))
                                    .frame(width: 48, height: 48)
                                Image(systemName: effect.icon)
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            .overlay(Circle().stroke(.white, lineWidth: selected ? 2.5 : 0))
                            Text(effect.titleKey.localized)
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
}
