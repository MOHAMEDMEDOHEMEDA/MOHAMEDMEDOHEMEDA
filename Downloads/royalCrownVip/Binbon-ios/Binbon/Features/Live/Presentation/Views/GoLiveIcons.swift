//
//  GoLiveIcons.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI

// MARK: - Video Camera Icon

struct VideoCameraIcon: View {
    
    var body: some View {
        VideoCameraShape()
            .overlay {
                VideoCameraShape()
                    .stroke(
                        AppColor.gold,
                        lineWidth: 4
                    )
                    .fill(LinearGradient(colors: [Color(hex: "83489C") , Color(hex: "EB7048") ], startPoint: .top, endPoint:.bottom))
            }
            .aspectRatio(VideoCameraShape.aspectRatio, contentMode: .fit)
    }
}

private struct VideoCameraShape: Shape {
    
    static let aspectRatio: CGFloat = 1.55
    
    func path(in rect: CGRect) -> Path {
        
        let w = rect.width
        let h = rect.height
        
        var path = Path()
        
        path.addRoundedRect(
            in: CGRect(
                x: 0,
                y: h * 0.02,
                width: w * 0.72,
                height: h
            ),
            cornerSize: CGSize(
                width: h * 0.22,
                height: h * 0.22
            )
        )
        
        path.move(to: CGPoint(x: w * 0.60, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.96, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.96, y: h * 0.80))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.66))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Live Broadcast Icon

struct LiveBroadcastIcon: View {
    
    var body: some View {
        GeometryReader { geo in
            
            let s = min(geo.size.width, geo.size.height)
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "83489C") , Color(hex: "EB7048") ], startPoint: .top, endPoint:.bottom))
                
                Circle()
                    .stroke(
                        AppColor.gold,
                        lineWidth: s * 0.05
                    )
                
                Image("record-binbon-logo")
                    .resizable()
                    .padding(s * 0.28)
            }
        }
    }
}
