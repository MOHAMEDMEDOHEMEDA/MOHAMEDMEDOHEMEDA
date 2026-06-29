//
//  CommercialDisclosureHelpIllustration.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureHelpIllustration: View {

    var body: some View {
        VStack(spacing: 4) {
            Image("cd-help-people")
                .resizable()
                .scaledToFit()
                .frame(width: 254)

            ZStack(alignment: .trailing) {
                Capsule()
                    .fill(Color(hex: "4CD964"))
                    .frame(width: 54, height: 17)
                Circle()
                    .fill(.black)
                    .frame(width: 13, height: 13)
                    .padding(2)
            }
            .frame(width: 54, height: 17)
            .padding(.top, 8)
            
            Image("cd-help-handshake")
                .resizable()
                .scaledToFit()
                .frame(width: 166)
        }
    }
}
