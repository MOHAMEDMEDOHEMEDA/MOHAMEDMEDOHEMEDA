//
//  CreateWheelMenu.swift
//  Binbon
//
//  Floating create menu: a fan of discrete circular action buttons that bloom
//  out of the tab bar's create button. Each is a purple disc with a gold ring,
//  a white icon, and (for the middle options) a label underneath.
//

import SwiftUI

enum CreateWheelOption: CaseIterable, Identifiable {
    case play, video, camera, layout, record, edit

    var id: Self { self }

    var icon: String {
        switch self {
        case .play:   "play.fill"
        case .video:  "video.fill"
        case .camera: "camera.fill"
        case .layout: "rectangle.split.3x1.fill"
        case .record: "record.circle.fill"
        case .edit:   "pencil"
        }
    }

    /// Caption shown under the button. The outermost options stay label-less.
    var titleKey: String? {
        switch self {
        case .video:  "video"
        case .camera: "photo"
        case .layout: "story"
        case .record: "live"
        case .play, .edit: nil
        }
    }
}

struct CreateWheelMenu: View {
    @Binding var isShown: Bool
    var onSelect: (CreateWheelOption) -> Void = { _ in }

    @State private var expanded = false

    private let options = CreateWheelOption.allCases
    private let circleSize: CGFloat = 56
    private let arcRadius: CGFloat = 130
    private let ringWidth: CGFloat = 1.5
    /// Buttons sit on an arc centred on straight-up (270°), 30° apart.
    private let startAngle: Double = 195
    private let stepAngle: Double = 30

    private var frameWidth: CGFloat { 2 * arcRadius + circleSize + 60 }
    private var frameHeight: CGFloat { arcRadius + circleSize + 8 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dim backdrop — tap anywhere to close.
            Color.black.opacity(expanded ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture { isShown = false }

            fan
                .frame(width: frameWidth, height: frameHeight, alignment: .bottom)
                .scaleEffect(expanded ? 1 : 0.1, anchor: .bottom)
                .opacity(expanded ? 1 : 0)
                .padding(.bottom, 18)
        }
        .allowsHitTesting(isShown)
        .onChange(of: isShown) { _, shown in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { expanded = shown }
        }
    }

    private var fan: some View {
        ZStack {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let center = arcPoint(index: index)

                button(option)
                    .position(center)
                    .onTapGesture { select(option) }

                if let key = option.titleKey {
                    Text(key.localized)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .fixedSize()
                        .position(x: center.x, y: center.y + circleSize / 2 + 14)
                }
            }
        }
    }

    // MARK: - Button
    private func button(_ option: CreateWheelOption) -> some View {
        ZStack {
            Circle().fill(AppColor.tabUnselectedGradient)
            Circle().stroke(Color.appYellow, lineWidth: ringWidth)
            Image(systemName: option.icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: circleSize, height: circleSize)
        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
    }

    /// Centre of the button at `index`, measured in the fan's bottom-anchored frame.
    private func arcPoint(index: Int) -> CGPoint {
        let theta = (startAngle + stepAngle * Double(index)) * .pi / 180
        return CGPoint(
            x: frameWidth / 2 + arcRadius * CGFloat(cos(theta)),
            y: frameHeight + arcRadius * CGFloat(sin(theta))
        )
    }

    // MARK: - Actions
    private func select(_ option: CreateWheelOption) {
        onSelect(option)
        isShown = false
    }
}
