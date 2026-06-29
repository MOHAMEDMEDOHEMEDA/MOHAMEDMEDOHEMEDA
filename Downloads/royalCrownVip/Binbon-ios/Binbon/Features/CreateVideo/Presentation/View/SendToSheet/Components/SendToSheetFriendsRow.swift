//
//  SendToSheetFriendsRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SendToSheetFriendsRow: View {

    let friends: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(friends.enumerated()), id: \.offset) { _, name in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "E6E6EA"))
                            .frame(width: 54, height: 54)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.gray)
                            )
                        Text(name)
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: 56)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
