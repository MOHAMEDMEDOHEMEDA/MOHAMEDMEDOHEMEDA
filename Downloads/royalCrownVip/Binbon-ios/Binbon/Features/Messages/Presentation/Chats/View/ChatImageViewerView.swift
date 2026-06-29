//
//  ChatImageViewerView.swift
//  Binbon
//

import SwiftUI

struct ChatImageViewerView: View {

    let images: [Data]
    @Binding var isPresented: Bool

    @State private var currentIndex: Int
    @State private var dragOffset: CGFloat = 0

    init(images: [Data], startIndex: Int, isPresented: Binding<Bool>) {
        self.images = images
        _isPresented = isPresented
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { i in
                    photoPage(images[i]).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: dragOffset)
            .simultaneousGesture(swipeDismissGesture)

            overlayControls
        }
        .ignoresSafeArea()
    }

    // MARK: - Controls overlay

    private var overlayControls: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
            }
            .padding(.top, 56)

            Spacer()

            if images.count > 1 {
                PageDots(count: images.count, current: currentIndex)
                    .padding(.bottom, 40)
            }
        }
        .opacity(1 - Double(min(dragOffset, 160) / 160))
    }

    // MARK: - Single photo page

    @ViewBuilder
    private func photoPage(_ data: Data) -> some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Color.gray.opacity(0.25)
        }
    }

    // MARK: - Swipe-down to dismiss

    private var swipeDismissGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                guard abs(v.translation.height) > abs(v.translation.width) else { return }
                dragOffset = max(0, v.translation.height)
            }
            .onEnded { _ in
                if dragOffset > 100 {
                    isPresented = false
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }
}
