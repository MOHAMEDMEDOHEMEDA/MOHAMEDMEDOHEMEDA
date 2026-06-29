//
//  FullScreenPhotoView.swift
//  Binbon
//

import SwiftUI
import UIKit

// MARK: - Full-screen photo

struct FullScreenPhotoView: View {
    let photoURLs: [String]
    let zoomID: String
    let namespace: Namespace.ID
    @Binding var isPresented: Bool
    @Binding var cardIndex: Int?

    @State private var currentIndex: Int?
    @State private var dragDown: CGFloat = 0    // swipe-to-dismiss travel
    @State private var faded = false            // iOS 17 fallback: cross-fade in/out

    init(photoURLs: [String], startIndex: Int, zoomID: String,
         namespace: Namespace.ID, isPresented: Binding<Bool>, cardIndex: Binding<Int?>) {
        self.photoURLs = photoURLs
        self.zoomID = zoomID
        self.namespace = namespace
        _isPresented = isPresented
        _cardIndex = cardIndex
        _currentIndex = State(initialValue: startIndex)
    }

    private let spring: Animation = .spring(response: 0.4, dampingFraction: 0.86)

    var body: some View {
        GeometryReader { geo in
            let screen = geo.size

            ZStack {
                Color.black.ignoresSafeArea()

                carousel(screen: screen, safeArea: geo.safeAreaInsets)
                    .offset(y: dragDown)

                controls(safeArea: geo.safeAreaInsets)
                    .opacity(controlsOpacity(in: screen))
            }
            .simultaneousGesture(dismissDrag)
        }
        .ignoresSafeArea()
        .opacity(fadeOpacity)
        .zoomDestination(id: zoomID, in: namespace)
        .onAppear {
            guard !isOS18 else { return }
            withAnimation(.easeInOut(duration: 0.25)) { faded = true }
        }
    }

    private var isOS18: Bool {
        if #available(iOS 18.0, *) { return true }
        return false
    }

    // iOS 18 leaves opacity alone (the zoom handles entry); pre-18 cross-fades.
    private var fadeOpacity: Double {
        isOS18 ? 1 : (faded ? 1 : 0)
    }

    // Controls fade out as the photo is dragged toward dismissal.
    private func controlsOpacity(in screen: CGSize) -> Double {
        1 - min(1, Double(dragDown / (screen.height * 0.4)))
    }

    // Each page stays full-width for clean paging, but the photo is inset above
    // the close button and below the page dots so it never touches the edges.
    private func carousel(screen: CGSize, safeArea: EdgeInsets) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, url in
                    FullScreenImage(url: url)
                        .padding(.top, safeArea.top + 16)
                        .padding(.bottom, safeArea.bottom + 16)
                        .frame(width: screen.width, height: screen.height)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .scrollIndicators(.hidden)
        .frame(width: screen.width, height: screen.height)
    }

    private func controls(safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: dismiss) {
                    Image("CommentClose")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(10)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("close".localized)
            }
            Spacer()
            if photoURLs.count > 1 {
                PageDots(count: photoURLs.count, current: currentIndex ?? 0)
                    .padding(.bottom, 24)
            }
        }
        .padding(.top, safeArea.top + 24)
        .padding(.bottom, safeArea.bottom)
        .padding(.horizontal, 12)
    }

    // Vertical drags dismiss; horizontal drags fall through to the carousel's own
    // paging. Runs alongside the ScrollView via simultaneousGesture.
    private var dismissDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                guard abs(value.translation.height) > abs(value.translation.width) else { return }
                dragDown = max(0, value.translation.height)
            }
            .onEnded { _ in
                if dragDown > 120 {
                    dismiss()
                } else {
                    withAnimation(spring) { dragDown = 0 }
                }
            }
    }

    private func dismiss() {
        if #available(iOS 18.0, *) {
            // Snap the drag offset back and sync the card to the photo on screen,
            // both instantly (card is still hidden), then let the system play the
            // zoom back into that now-matching photo.
            var transaction = SwiftUI.Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                dragDown = 0
                cardIndex = currentIndex
            }
            isPresented = false
        } else {
            withAnimation(.easeInOut(duration: 0.25)) { faded = false; dragDown = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                var transaction = SwiftUI.Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    cardIndex = currentIndex
                    isPresented = false
                }
            }
        }
    }
}

// A single full-screen photo scaled to fit. Pulls from the shared image cache,
// so a photo already shown in the card appears instantly.
private struct FullScreenImage: View {
    let url: String

    @State private var image: UIImage?
    @State private var didLoad = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if didLoad {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            } else {
                ProgressView().tint(.white)
            }
        }
        .task {
            image = await Network.shared.image(url)
            didLoad = true
        }
    }
}
