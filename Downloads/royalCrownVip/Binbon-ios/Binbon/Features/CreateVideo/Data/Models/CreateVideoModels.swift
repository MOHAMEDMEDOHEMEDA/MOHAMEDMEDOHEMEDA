//
//  CreateVideoModels.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

// MARK: - Layout Option
enum VideoLayoutOption: Int, CaseIterable, Identifiable {
    case single
    case sideBySide
    case corner
    case stacked

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .single:     "square"
        case .sideBySide: "rectangle.split.2x1"
        case .corner:     "square.split.bottomrightquarter"
        case .stacked:    "rectangle.split.1x2"
        }
    }

    func panes(for size: CGSize) -> (camera: CGRect, image: CGRect?, imageIsCorner: Bool) {
        let full = CGRect(origin: .zero, size: size)
        switch self {
        case .single:
            return (full, nil, false)
        case .sideBySide:
            let w = size.width / 2
            let bandH = size.height * 0.4
            let y = (size.height - bandH) / 2
            return (CGRect(x: 0, y: y, width: w, height: bandH),
                    CGRect(x: w, y: y, width: size.width - w, height: bandH), false)
        case .stacked:
            let h = size.height / 2
            return (CGRect(x: 0, y: 0, width: size.width, height: h),
                    CGRect(x: 0, y: h, width: size.width, height: size.height - h), false)
        case .corner:
            let w = size.width * 0.30, h = size.height * 0.24
            let pip = CGRect(x: 16, y: 110, width: w, height: h)
            return (full, pip, true)
        }
    }
}

// MARK: - Side Control
struct VideoSideControl: Identifiable {
    let id = UUID()
    let icon: String
    let isDestructive: Bool
    let isActive: Bool
    let action: () -> Void

    init(icon: String,
         isDestructive: Bool = false,
         isActive: Bool = false,
         action: @escaping () -> Void = {}) {
        self.icon = icon
        self.isDestructive = isDestructive
        self.isActive = isActive
        self.action = action
    }
}
