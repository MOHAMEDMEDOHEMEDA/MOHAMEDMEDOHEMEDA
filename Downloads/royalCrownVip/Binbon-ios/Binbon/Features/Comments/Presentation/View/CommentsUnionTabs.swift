//
//  CommentsUnionTabs.swift
//  Binbon
//
//  The folder-tab "union" for the comments sheet — like the Live page tabs but
//  generalized to N tabs: the selected tab's ear fuses with the content panel
//  into one continuous shape, while the other tabs sit behind as separate folders.
//

import SwiftUI

/// One continuous outline fusing the selected tab's ear (at `selectedIndex`)
/// with the full content panel below it.
struct CommentsUnionShape: Shape {
    var selectedIndex: Int
    var count: Int
    var earHeight: CGFloat
    var cornerRadius: CGFloat = 12
    var portal: CGFloat = 10
    /// When false the outline is left open along the bottom — used to stroke the
    /// tabs + sides without a closing line under the content.
    var closed: Bool = true

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let slot = w / CGFloat(max(count, 1))
        let r = max(0, min(cornerRadius, slot / 2))
        let earH = min(earHeight, h)
        let pw = max(0, min(portal, slot / 3, earH / 3))

        let eS = CGFloat(selectedIndex) * slot
        let eE = eS + slot
        let atLeft = selectedIndex == 0
        let atRight = selectedIndex == count - 1

        var p = Path()
        p.move(to: CGPoint(x: 0, y: h - r))

        // Up the leading edge into the ear (left edge) or panel top-left corner.
        if atLeft {
            p.addLine(to: CGPoint(x: 0, y: r))
            p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        } else {
            p.addLine(to: CGPoint(x: 0, y: earH + r))
            p.addQuadCurve(to: CGPoint(x: r, y: earH), control: CGPoint(x: 0, y: earH))
            p.addLine(to: CGPoint(x: eS - pw, y: earH))
            p.addQuadCurve(to: CGPoint(x: eS, y: earH - pw), control: CGPoint(x: eS, y: earH))
            p.addLine(to: CGPoint(x: eS, y: r))
            p.addQuadCurve(to: CGPoint(x: eS + r, y: 0), control: CGPoint(x: eS, y: 0))
        }

        // Ear top → down the trailing side (or merge into the panel right edge).
        if atRight {
            p.addLine(to: CGPoint(x: w - r, y: 0))
            p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        } else {
            p.addLine(to: CGPoint(x: eE - r, y: 0))
            p.addQuadCurve(to: CGPoint(x: eE, y: r), control: CGPoint(x: eE, y: 0))
            p.addLine(to: CGPoint(x: eE, y: earH - pw))
            p.addQuadCurve(to: CGPoint(x: eE + pw, y: earH), control: CGPoint(x: eE, y: earH))
            p.addLine(to: CGPoint(x: w - r, y: earH))
            p.addQuadCurve(to: CGPoint(x: w, y: earH + r), control: CGPoint(x: w, y: earH))
        }

        // Right edge down to the bottom corner.
        p.addLine(to: CGPoint(x: w, y: h - r))

        // Bottom edge → back to start (omitted when open).
        if closed {
            p.addQuadCurve(to: CGPoint(x: w - r, y: h), control: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: r, y: h))
            p.addQuadCurve(to: CGPoint(x: 0, y: h - r), control: CGPoint(x: 0, y: h))
            p.closeSubpath()
        }
        return p
    }
}

/// Background that draws the unselected tabs behind, then the fused
/// selected-ear-plus-panel union on top, both gold-bordered.
struct CommentsUnionBackground: View {
    let selectedIndex: Int
    let count: Int
    var earHeight: CGFloat = 52
    var cornerRadius: CGFloat = 12
    /// Fill for the tabs + panel. Defaults to the comments sheet gradient; the
    /// profile video tabs pass the screen background so they blend in.
    var fill: AnyShapeStyle = AnyShapeStyle(AppColor.shareSheetGradient)
    /// When false the gold outline is left open along the bottom.
    var strokeBottom: Bool = true

    var body: some View {
        GeometryReader { geo in
            let slot = geo.size.width / CGFloat(max(count, 1))
            let r = cornerRadius

            ZStack(alignment: .topLeading) {
                // Unselected tabs sit behind; their bottoms tuck under the panel.
                ForEach(0..<count, id: \.self) { index in
                    if index != selectedIndex {
                        let shape = UnevenRoundedRectangle(
                            topLeadingRadius: r, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0, topTrailingRadius: r, style: .continuous
                        )
                        shape
                            .fill(fill)
                            .overlay(shape.stroke(AppColor.gold, lineWidth: 1.5))
                            .frame(width: slot, height: earHeight + 24)
                            .offset(x: CGFloat(index) * slot, y: 0)
                    }
                }

                CommentsUnionShape(selectedIndex: selectedIndex, count: count, earHeight: earHeight, cornerRadius: r)
                    .fill(fill)

                CommentsUnionShape(selectedIndex: selectedIndex, count: count, earHeight: earHeight, cornerRadius: r, closed: strokeBottom)
                    .stroke(AppColor.gold, lineWidth: 2)
            }
        }
    }
}
