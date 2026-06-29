//
//  ReelHearts.swift
//  Binbon
//

import SwiftUI

struct FlyingHeart: Identifiable, Equatable {
    let id: UUID
    let start: CGPoint
}

struct FlyingHeartsLayer: View {
    let hearts: [FlyingHeart]
    let target: CGPoint

    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                FlyingHeartView(heart: heart, target: target)
            }
        }
    }
}

struct FlyingHeartView: View {
    let heart: FlyingHeart
    let target: CGPoint

    @State private var didAppear = false
    @State private var didFly = false

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 110, weight: .bold))
            .foregroundStyle(.red.opacity(0.8))
            .position(didFly ? target : heart.start)
            .scaleEffect(didFly ? 0.25 : (didAppear ? 1.0 : 0.3))
            .rotationEffect(.degrees(didAppear ? -8 : 0))
            .opacity(didFly ? 0 : 1)
            .onAppear {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    didAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeIn(duration: 0.7)) {
                        didFly = true
                    }
                }
            }
    }
}

struct LikedHeartsBurst: View {
    @State private var animate = false

    private let count = 3

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.red.opacity(0.85))
                        .shadow(color: .black.opacity(0.4), radius: 6)
                        .position(
                            x: animate ? geo.size.width * 0.85 : geo.size.width * 0.12,
                            y: geo.size.height * (0.42 + Double(index) * 0.08)
                        )
                        .opacity(animate ? 0 : 1)
                        .scaleEffect(animate ? 1.1 : 0.7)
                        .animation(
                            .easeOut(duration: 1.6).delay(Double(index) * 0.18),
                            value: animate
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
