//
//  LoadingModifier.swift
//  Binbon
//
//  Created by Salah Khaled on 12/05/2026.
//

import SwiftUI

private struct LoadingModifier: ViewModifier {
    
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .tint(.black)
                    .frame(width: 60, height: 60)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

extension View {
    func loadingOverlay(_ isLoading: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
}
