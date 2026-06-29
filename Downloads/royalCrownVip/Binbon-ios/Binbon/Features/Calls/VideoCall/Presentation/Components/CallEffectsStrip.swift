//  CallEffectsStrip.swift
//  Binbon

import SwiftUI

/// Transparent horizontal effect selector that floats over the bottom video tile.
/// Fixed search / reset buttons on the left, then scrollable color swatches from
/// the caller's `effects` array. The selected swatch grows and shows its label.
struct CallEffectsStrip: View {

    let effects: [(key: String, color: Color)]
    @Binding var selectedIndex: Int
    var onClose: () -> Void
    var onReset: () -> Void

    private let selectedSize:   CGFloat = 55
    private let unselectedSize: CGFloat = 40
    private let labelHeight:    CGFloat = 16

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 12) {
                controlCircle(
                    systemName:       "magnifyingglass",
                    accessibilityKey: "voice_call_effects_search",
                    action:           onClose
                )
                Spacer()


                ForEach(effects.indices, id: \.self) { i in
                    effectItem(at: i)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Fixed control buttons

    private func controlCircle(
        systemName: String,
        accessibilityKey: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColor.backgroundGradient)
                    .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 1))
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: unselectedSize, height: unselectedSize)
            // Invisible label placeholder keeps bottom-alignment with effect items.
            .padding(.top, labelHeight + 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.localized)
    }

    // MARK: - Scrollable effect swatches

    private func effectItem(at index: Int) -> some View {
        let isSelected = index == selectedIndex
        let size: CGFloat = isSelected ? selectedSize : unselectedSize
        let effect = effects[index]

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) { selectedIndex = index }
        } label: {
            VStack(spacing: 5) {
                // Fixed-height slot keeps the row from shifting when the label appears.
                Text(effect.key.localized)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.45), radius: 2, y: 1)
                    .lineLimit(1)
                    .frame(height: labelHeight)
                    .opacity(isSelected ? 1 : 0)

                ZStack {
                    Circle()
                        .fill(effect.color == .clear
                              ? AnyShapeStyle(.white.opacity(0.18))
                              : AnyShapeStyle(effect.color))

                    if effect.color == .clear {
                        Image(systemName: "circle.slash")
                            .font(.system(size: size * 0.34, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Circle()
                        .stroke(
                            isSelected ? Color.white : Color.white.opacity(0.25),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                }
                .frame(width: size, height: size)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
        .accessibilityLabel(effect.key.localized)
    }
}
