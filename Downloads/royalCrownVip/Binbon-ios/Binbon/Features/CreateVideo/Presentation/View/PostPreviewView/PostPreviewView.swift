//
//  PostPreviewView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import SwiftUI

struct PostPreviewView: View {

    let videoURL: URL?
    var image: UIImage? = nil
    var layout: VideoLayoutOption = .single
    var overlays: [VideoOverlayItem] = []
    var authorAvatar: UIImage? = nil
    var caption: String = ""
    var photoScale: CGFloat = 1
    var photoRotation: Angle = .zero
    var onClose: () -> Void = {}

    @State private var overlaysState: [VideoOverlayItem] = []
    @State private var noSelection: UUID?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CapturedVideoLayoutView(videoURL: videoURL, image: image, layout: layout,
                                    photoScale: photoScale, photoRotation: photoRotation)
                .ignoresSafeArea()

            VideoEditorOverlayLayer(overlays: $overlaysState, editable: false, selectedID: $noSelection)
                .allowsHitTesting(false)

            VStack {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.35)))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                Spacer()
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    authorRow
                    Spacer()
                    actionRail
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 90)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            overlaysState = overlays
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }

    // MARK: - Author row (bottom-left)
    private var authorRow: some View {
        HStack(spacing: 10) {
            Group {
                if let authorAvatar {
                    Image(uiImage: authorAvatar).resizable().scaledToFill()
                } else {
                    Circle().fill(AppColor.buttonGradient)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.white))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.appGold, lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("@\("your_story".localized)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                if !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
            }
            .shadow(color: .black.opacity(0.6), radius: 2)
        }
    }

    // MARK: - Action rail (bottom-right)
    private var actionRail: some View {
        VStack(spacing: 18) {
            railIcon("heart.fill", "0")
            railIcon("bubble.right.fill", "0")
            railIcon("bookmark.fill", "0")
            railIcon("arrowshape.turn.up.forward.fill", "0")
        }
        .foregroundStyle(.white)
    }

    private func railIcon(_ symbol: String, _ count: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 28, weight: .semibold))
                .shadow(color: .black.opacity(0.5), radius: 3)
            Text(count)
                .font(.system(size: 12, weight: .semibold))
                .shadow(color: .black.opacity(0.5), radius: 2)
        }
    }
}
