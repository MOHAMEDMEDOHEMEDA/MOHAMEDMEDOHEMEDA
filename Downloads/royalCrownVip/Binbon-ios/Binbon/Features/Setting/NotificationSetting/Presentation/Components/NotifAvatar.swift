//
//  NotifAvatar.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifAvatar: View {
    let name: String
    var imageURL: String? = nil

    /// Border gradient from the Figma design: maroon → purple → orange (vertical).
    private static let borderGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "7C0930"), location: 0.0),
            .init(color: Color(hex: "83489C"), location: 0.42),
            .init(color: Color(hex: "EB7048"), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    var body: some View {
        content
            .frame(width: 40, height: 45)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Self.borderGradient)
            )
    }

    @ViewBuilder
    private var content: some View {
        if let imageURL, !imageURL.isEmpty {
            ImageView(imageURL)
        } else {
            Text(initials)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColor.buttonGradient)
        }
    }
}
