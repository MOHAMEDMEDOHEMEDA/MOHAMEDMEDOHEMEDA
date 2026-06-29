//
//  ReelLabelStyle.swift
//  Binbon
//

import SwiftUI

struct VerticalLabelStyle: LabelStyle {
    var spacing: CGFloat = 4
    var iconFont: Font = .title3.weight(.semibold)
    var titleFont: Font = .footnote.weight(.medium)
    var iconColor: Color = .white
    var titleColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: spacing) {
            configuration.icon
                .font(iconFont)
                .foregroundStyle(iconColor)
                .shadow(color: .black.opacity(0.6), radius: 10)
            configuration.title
                .font(titleFont)
                .foregroundStyle(titleColor)
                .shadow(color: .black.opacity(0.6), radius: 4)
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static var vertical: VerticalLabelStyle { VerticalLabelStyle() }
    static func vertical(icon: Color = .white, title: Color = .white) -> VerticalLabelStyle {
        VerticalLabelStyle(iconColor: icon, titleColor: title)
    }
}
