//
//  AppNavbar.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import SwiftUI

struct AppNavbar: View {
    
    let title: String
    var onBack: (() -> Void)?
    
    var body: some View {
        HStack {
            
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.appText)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .background(.gray.opacity(0.05), in: Capsule())
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
            Spacer()
            
            Text(title)
                .foregroundColor(.appText)
                .font(.headline.bold())
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}
