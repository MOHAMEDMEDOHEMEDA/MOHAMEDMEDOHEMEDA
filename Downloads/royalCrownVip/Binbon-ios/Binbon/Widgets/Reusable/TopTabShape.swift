//
//  TopTabShape.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import SwiftUI

struct FolderTabOpenShape: Shape {
    var openOnLeft: Bool = true
    var fullTab: Bool = false
    var cornerRadius: CGFloat = 20
    var carveRadius: CGFloat = 16
    var valleyDepth: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let mid = w / 2
        let R = max(0, min(cornerRadius, mid, h))

        if fullTab {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: 0, y: R))
            p.addQuadCurve(to: CGPoint(x: R, y: 0), control: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: w - R, y: 0))
            p.addQuadCurve(to: CGPoint(x: w, y: R), control: CGPoint(x: w, y: 0))
            p.addLine(to: CGPoint(x: w, y: h))
            return p
        }

        let c = max(0, min(carveRadius, mid - R))
        let v = max(0, min(valleyDepth, h))
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: R))
        p.addQuadCurve(to: CGPoint(x: R, y: 0), control: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: mid - c, y: 0))
        p.addQuadCurve(to: CGPoint(x: mid, y: v), control: CGPoint(x: mid, y: 0))
        return openOnLeft ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

struct FolderTabClosedShape: Shape {
    var openOnLeft: Bool = true
    var fullTab: Bool = false
    var cornerRadius: CGFloat = 20
    var carveRadius: CGFloat = 16
    var valleyDepth: CGFloat = 9

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let mid = w / 2
        let R = max(0, min(cornerRadius, mid, h))

        if fullTab {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: h))
            p.addLine(to: CGPoint(x: 0, y: R))
            p.addQuadCurve(to: CGPoint(x: R, y: 0), control: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: w - R, y: 0))
            p.addQuadCurve(to: CGPoint(x: w, y: R), control: CGPoint(x: w, y: 0))
            p.addLine(to: CGPoint(x: w, y: h))
            p.closeSubpath()
            return p
        }

        let c = max(0, min(carveRadius, mid - R))
        let v = max(0, min(valleyDepth, h))
        var p = Path()
        p.move(to: CGPoint(x: mid, y: h))
        p.addLine(to: CGPoint(x: mid, y: v))
        p.addQuadCurve(to: CGPoint(x: mid + c, y: 0), control: CGPoint(x: mid, y: 0))
        p.addLine(to: CGPoint(x: w - R, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: R), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return openOnLeft ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

// MARK: - Folder tabs with a "portal" trailing edge (Figma 616:496304)

/// The selected tab: a rounded-top "ear" whose trailing edge flares outward
/// through a smooth portal curve into the content panel, left open at the bottom
/// so it blends into the content below. `leftActive` places it on the leading half.
struct FolderActiveTabShape: Shape {
    var leftActive: Bool = true
    var cornerRadius: CGFloat = 11
    var bodyFraction: CGFloat = 0.5
    var portalWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, h, w * 0.25))
        let bodyRight = w * bodyFraction
        let pw = max(0, min(portalWidth, h, bodyRight))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))                                   // baseline (leading)
        p.addLine(to: CGPoint(x: 0, y: r))                               // up the leading edge
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))     // top-leading corner
        p.addLine(to: CGPoint(x: bodyRight - r, y: 0))                  // flat top
        p.addQuadCurve(to: CGPoint(x: bodyRight, y: r), control: CGPoint(x: bodyRight, y: 0)) // top-trailing corner
        p.addLine(to: CGPoint(x: bodyRight, y: h - pw))                 // down the trailing edge
        p.addQuadCurve(to: CGPoint(x: bodyRight + pw, y: h),
                       control: CGPoint(x: bodyRight, y: h))             // portal flare into the baseline
        // open bottom — fill closes it implicitly; stroke leaves it open
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// The unselected tab: a rounded-top rectangle on the opposite half, sitting
/// behind the active tab with its leading corner tucked under the portal flare.
struct FolderInactiveTabShape: Shape {
    var leftActive: Bool = true
    var cornerRadius: CGFloat = 11
    var bodyFraction: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, h, w * 0.25))
        let divider = w * bodyFraction

        var p = Path()
        p.move(to: CGPoint(x: divider, y: h))
        p.addLine(to: CGPoint(x: divider, y: r))
        p.addQuadCurve(to: CGPoint(x: divider + r, y: 0), control: CGPoint(x: divider, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// Open path tracing only the top edge (with rounded top corners) of a tab —
/// used to stroke a border on the top of the unselected sub-tab only.
struct TabTopBorderShape: Shape {
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, w / 2, h))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: r))
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        return p
    }
}

// MARK: - Full Union (selected tab ear + portal + content panel) — Figma 616:496307

/// One continuous outline fusing the selected tab's rounded top "ear" with the
/// content panel below it: across the ear top, down its inner edge, through the
/// portal curve into the panel top, then around the full panel. `leftActive`
/// places the ear on the geometric left (caller flips it for RTL).
struct LiveUnionShape: Shape {
    var leftActive: Bool = true
    var earHeight: CGFloat = 39
    var bodyFraction: CGFloat = 0.5
    var cornerRadius: CGFloat = 12
    var portalWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, w / 2))
        let earH = min(max(earHeight, r), h)
        let bodyRight = w * bodyFraction
        let pw = max(0, min(portalWidth, bodyRight, earH))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: r))                                                     // left edge, below ear top-leading
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))               // ear top-leading corner
        p.addLine(to: CGPoint(x: bodyRight - r, y: 0))                                      // ear top
        p.addQuadCurve(to: CGPoint(x: bodyRight, y: r), control: CGPoint(x: bodyRight, y: 0)) // ear top-trailing corner
        p.addLine(to: CGPoint(x: bodyRight, y: earH - pw))                                  // down ear inner edge
        p.addQuadCurve(to: CGPoint(x: bodyRight + pw, y: earH), control: CGPoint(x: bodyRight, y: earH)) // portal into panel top
        p.addLine(to: CGPoint(x: w - r, y: earH))                                           // panel top edge
        p.addQuadCurve(to: CGPoint(x: w, y: earH + r), control: CGPoint(x: w, y: earH))     // panel top-trailing corner
        p.addLine(to: CGPoint(x: w, y: h - r))                                              // panel trailing edge
        p.addQuadCurve(to: CGPoint(x: w - r, y: h), control: CGPoint(x: w, y: h))           // panel bottom-trailing
        p.addLine(to: CGPoint(x: r, y: h))                                                  // panel bottom
        p.addQuadCurve(to: CGPoint(x: 0, y: h - r), control: CGPoint(x: 0, y: h))           // panel bottom-leading
        p.addLine(to: CGPoint(x: 0, y: r))                                                  // leading edge up
        p.closeSubpath()
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// Open path tracing only the selected tab's ear outline (leading edge, top,
/// inner edge, portal) — stops at the panel junction so the content container is
/// left without a border. Mirrors in RTL via `leftActive`.
struct LiveUnionEarBorderShape: Shape {
    var leftActive: Bool = true
    var earHeight: CGFloat = 39
    var bodyFraction: CGFloat = 0.5
    var cornerRadius: CGFloat = 12
    var portalWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let r = max(0, min(cornerRadius, w / 2))
        let earH = min(max(earHeight, r), rect.height)
        let bodyRight = w * bodyFraction
        let pw = max(0, min(portalWidth, bodyRight, earH))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: earH))                                                  // ear bottom-leading (panel junction)
        p.addLine(to: CGPoint(x: 0, y: r))                                                  // up the leading edge
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))               // top-leading corner
        p.addLine(to: CGPoint(x: bodyRight - r, y: 0))                                      // ear top
        p.addQuadCurve(to: CGPoint(x: bodyRight, y: r), control: CGPoint(x: bodyRight, y: 0)) // top-trailing corner
        p.addLine(to: CGPoint(x: bodyRight, y: earH - pw))                                  // down inner edge
        p.addQuadCurve(to: CGPoint(x: bodyRight + pw, y: earH), control: CGPoint(x: bodyRight, y: earH)) // portal into panel top
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// The unselected tab: a rounded-top rectangle filling the top strip on the half
/// opposite the union ear. Drawn behind the union so its bottom tucks under the
/// panel's top edge.
struct LiveUnionInactiveTabShape: Shape {
    var leftActive: Bool = true
    var earHeight: CGFloat = 39
    var bodyFraction: CGFloat = 0.5
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let r = max(0, min(cornerRadius, w / 4))
        let earH = min(earHeight, rect.height)
        let divider = w * bodyFraction

        var p = Path()
        p.move(to: CGPoint(x: divider, y: earH))
        p.addLine(to: CGPoint(x: divider, y: r))
        p.addQuadCurve(to: CGPoint(x: divider + r, y: 0), control: CGPoint(x: divider, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: earH))
        p.closeSubpath()
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// Open path tracing only the top edge (with rounded top corners) of the
/// unselected tab in the union layout — used to stroke its top border.
struct LiveUnionInactiveTopBorderShape: Shape {
    var leftActive: Bool = true
    var bodyFraction: CGFloat = 0.5
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let r = max(0, min(cornerRadius, w / 4))
        let divider = w * bodyFraction

        var p = Path()
        p.move(to: CGPoint(x: divider, y: r))
        p.addQuadCurve(to: CGPoint(x: divider + r, y: 0), control: CGPoint(x: divider, y: 0))
        p.addLine(to: CGPoint(x: w - r, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
        return leftActive ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}

/// Open path tracing the top edge plus the inner vertical edge of the selected
/// sub-tab (its leading edge and bottom are left open so it blends into the
/// content like the Figma "Union"). `innerTrailing` puts the stroked side on the
/// trailing edge — true when the selected tab is the leading one. Mirrors in RTL.
struct SelectedTabBorderShape: Shape {
    var cornerRadius: CGFloat = 12
    var innerTrailing: Bool = true

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = max(0, min(cornerRadius, w / 2, h))

        var p = Path()
        p.move(to: CGPoint(x: 0, y: r))                                        // top of the open leading edge
        p.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))  // top-leading corner
        p.addLine(to: CGPoint(x: w - r, y: 0))                                // top edge
        p.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))  // top-trailing corner
        p.addLine(to: CGPoint(x: w, y: h))                                    // inner (trailing) edge to the baseline
        return innerTrailing ? p : p.applying(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: w, ty: 0))
    }
}
