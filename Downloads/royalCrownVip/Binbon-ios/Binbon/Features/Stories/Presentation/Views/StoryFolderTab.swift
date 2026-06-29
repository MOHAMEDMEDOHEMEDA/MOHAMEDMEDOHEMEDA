//
//  StoryFolderTab.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI

struct StoryFolderTab<Label: View>: View {

    let isSelected: Bool
    var cornerRadius: CGFloat = 11
    var horizontalPadding: CGFloat = 10
    var verticalPadding: CGFloat = 10
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background {
                    UnevenRoundedRectangle(
                        topLeadingRadius: cornerRadius,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(
                        isSelected
                        ? AnyShapeStyle(AppColor.storyPanelFill)
                        : AnyShapeStyle(AppColor.liveSubTabGradient)
                    )
                }
                .overlay {
                    if isSelected {
                        StoryActiveTabOutline(cornerRadius: cornerRadius)
                            .stroke(AppColor.gold, lineWidth: 2)
                    } else {
                        UnevenRoundedRectangle(
                            topLeadingRadius: cornerRadius,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: cornerRadius,
                            style: .continuous
                        )
                        .stroke(AppColor.gold, lineWidth: 2)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct StoryActiveTabOutline: Shape {

    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, w / 2, h))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h))
        return p
    }
}
