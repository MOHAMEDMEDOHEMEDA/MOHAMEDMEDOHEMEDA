//
//  AppMessage.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import SwiftUI

struct AppMessage: View {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundColor(.appText.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
                .padding(.horizontal, 10)
            Spacer()
        }
    }
}
