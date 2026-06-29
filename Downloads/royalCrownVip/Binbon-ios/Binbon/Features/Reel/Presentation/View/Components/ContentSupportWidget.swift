//
//  ContentSupportWidget.swift
//  Binbon
//
//  The reel "Content support" affordance. Collapsed it's a transparent
//  gift + label + chevron pill; tapping expands it into a gradient panel
//  with Support / Promotion actions (Figma node 1795-36842).
//

import SwiftUI

struct ContentSupportWidget: View {
    var onSupport: () -> Void = {}
    var onPromotion: () -> Void = {}

    @State private var isOpen = false

    var body: some View {
        // The collapsed pill always holds its place in the layout so opening
        // never shifts the surrounding controls. The expanded panel floats on
        // top of it as an overlay, anchored to the pill's bottom-trailing corner.
        collapsedPill
            .opacity(isOpen ? 0 : 1)
            .overlay(alignment: .bottomTrailing) {
                if isOpen {
                    openPanel
                        .fixedSize()
                        .transition(.scale(scale: 0.2, anchor: .bottomTrailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isOpen)
    }

    // Collapsed: gift + label + chevron, no background.
    private var collapsedPill: some View {
        Button {
            isOpen = true
        } label: {
            header(chevron: "chevron.right")
                .padding(8)
        }
        .buttonStyle(.plain)
    }

    // Expanded: gradient panel with the two actions.
    private var openPanel: some View {
        VStack(spacing: 16) {
            Button {
                isOpen = false
            } label: {
                header(chevron: "chevron.up")
            }
            .buttonStyle(.plain)

            VStack(spacing: 8) {
                actionButton("support".localized, action: onSupport)
                actionButton("promotion".localized, action: onPromotion)
            }
        }
        .padding(8)
        .frame(width: 128)
        .background(AppColor.contentSupportPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func header(chevron: String) -> some View {
        HStack(spacing: 5) {
            Image("cs-gift")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)

            Text("content_support".localized)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Image(systemName: chevron)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.4), radius: 3)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(AppColor.contentSupportButton)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
