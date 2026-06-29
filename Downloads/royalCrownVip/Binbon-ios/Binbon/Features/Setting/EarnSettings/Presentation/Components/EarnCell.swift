//
//  EarnCell.swift
//  Binbon
//
//  Created by Husayn on 07/06/2026.
//

import SwiftUI

struct EarnCell: View {
    let coinAmount: String
    let price: String
    let date: String
    
    var body: some View {
        HStack(spacing: 8) {
            
            // MARK: - Icon (Right)
            Image(systemName: "bag.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundStyle(.appText)

            // MARK: - Text Content (Center)
            VStack(alignment: .leading, spacing: 6) {
                Text("you_have_successfully_chraged".localized + "  \(coinAmount) " + "coins_to_your_account".localized)
                    .font(.system(size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(.appText)
                    .multilineTextAlignment(.leading)
                
                Text("$ \(price)")
                    .font(.system(size: 11))
                    .fontWeight(.regular)
                    .foregroundStyle(.appText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(date)
                .font(.system(size: 10))
                .fontWeight(.regular)
                .foregroundColor(Color(hex: "FBBC05"))
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    EarnCell(coinAmount: "797997",
             price: "9.99",
             date: "12 December 2025"
    )
}
