//
//  PoppingHeartView.swift
//  Binbon
//

import SwiftUI

// MARK: - Double-tap like heart

struct PoppingHeart: Identifiable {
    let id = UUID()
    let position: CGPoint
}

struct PoppingHeartView: View {
    let position: CGPoint

    @State private var appeared = false
    @State private var faded = false

    init(at position: CGPoint) { self.position = position }

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 90, weight: .bold))
            .foregroundStyle(.red.opacity(0.8))
            .shadow(color: .black.opacity(0.35), radius: 8)
            .scaleEffect(appeared ? (faded ? 1.25 : 1.0) : 0.3)
            .rotationEffect(.degrees(appeared ? -10 : 0))
            .opacity(faded ? 0 : 1)
            .position(position)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    appeared = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeOut(duration: 0.45)) { faded = true }
                }
            }
    }
}
