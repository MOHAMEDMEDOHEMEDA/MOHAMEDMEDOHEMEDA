//
//  DiscloseToggle.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct DiscloseToggle: View {

    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color(hex: "4CD964") : Color.appText.opacity(0.3))
                .frame(width: 34, height: 17)
            Circle()
                .fill(.white)
                .frame(width: 13, height: 13)
                .padding(2)
        }
        .frame(width: 34, height: 17)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) { isOn.toggle() }
        }
    }
}
