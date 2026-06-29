//
//  NotifCircleIcon.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI


struct NotifCircleIcon: View {
    let name: String
    var background: Color
    var iconColor: Color = .white
    var diameter: CGFloat = 30
    var iconSize: CGFloat = 18

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
            .foregroundStyle(iconColor)
            .frame(width: diameter, height: diameter)
            .background(background, in: Circle())
    }
}
