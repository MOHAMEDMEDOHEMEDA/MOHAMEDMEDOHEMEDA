//
//  NotifMessageIcon.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifMessageIcon: View {
    var body: some View {
        Image("notif-message")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
            .foregroundStyle(.appText)
            .frame(width: 24, height: 24)
            .background(AppColor.buttonGradient, in: Circle())
    }
}
