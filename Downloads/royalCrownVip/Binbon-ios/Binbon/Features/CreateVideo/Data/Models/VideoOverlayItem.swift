//
//  VideoOverlayItem.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoOverlayItem: Identifiable, Equatable {

    enum Kind: Equatable {
        case text(String, fontName: String, fontSize: CGFloat, colorHex: String)
        case sticker(String)
    }

    let id = UUID()
    var kind: Kind
    var offset: CGSize = .zero
    var scale: CGFloat = 1
    var rotation: Angle = .zero
}

enum OverlayFont: String, CaseIterable, Identifiable {
    case system = "System"
    case rounded = "Rounded"
    case serif = "Serif"
    case mono = "Mono"

    var id: String { rawValue }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:  return .system(size: size, weight: .bold)
        case .rounded: return .system(size: size, weight: .bold, design: .rounded)
        case .serif:   return .system(size: size, weight: .bold, design: .serif)
        case .mono:    return .system(size: size, weight: .bold, design: .monospaced)
        }
    }
}

enum OverlayPalette {
    static let hexes = ["FFFFFF", "000000", "E14554", "FBBC05", "4CD964",
                        "3D9BFF", "83489C", "FF8A3D", "FF4D6D", "7FE3FF"]
}
