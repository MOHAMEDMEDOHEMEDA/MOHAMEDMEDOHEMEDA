//
//  NotifSwitchStyle.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Capsule()
                .fill(configuration.isOn ? Color(hex: "4CD964") : Color(hex: "C0C0C0"))
                .frame(width: 34, height: 17)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 13, height: 13)
                        .padding(2)
                        .frame(maxWidth: .infinity,
                               alignment: configuration.isOn ? .trailing : .leading)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
