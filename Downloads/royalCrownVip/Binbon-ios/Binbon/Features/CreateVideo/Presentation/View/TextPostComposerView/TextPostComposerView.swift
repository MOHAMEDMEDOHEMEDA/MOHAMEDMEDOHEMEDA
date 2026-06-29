//
//  TextPostComposerView.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct TextPostComposerView: View {

    var onClose: () -> Void = {}
    var onNext: (UIImage) -> Void = { _ in }

    @State private var text = ""
    @State private var backgroundIndex = 0
    @FocusState private var focused: Bool

    private let backgrounds: [[Color]] = [
        [Color(hex: "E2704A"), Color(hex: "8E4C9E")],
        [Color(hex: "1D976C"), Color(hex: "93F9B9")],
        [Color(hex: "2C3E50"), Color(hex: "4CA1AF")],
        [Color(hex: "C94B4B"), Color(hex: "4B134F")],
        [Color(hex: "000000"), Color(hex: "434343")]
    ]

    private var gradient: LinearGradient {
        LinearGradient(colors: backgrounds[backgroundIndex], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            canvas

            VStack {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button { withAnimation { backgroundIndex = (backgroundIndex + 1) % backgrounds.count } } label: {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                Button {
                    focused = false
                    if let image = render() { onNext(image) }
                } label: {
                    Text("next".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
                .opacity(text.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { focused = true }
    }

    private var canvas: some View {
        ZStack {
            gradient.ignoresSafeArea()
            TextField("", text: $text, axis: .vertical)
                .focused($focused)
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .tint(.white)
                .padding(.horizontal, 28)
        }
    }

    @MainActor private func render() -> UIImage? {
        let snapshot = ZStack {
            gradient
            Text(text)
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
        }
        .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: snapshot)
        renderer.scale = 1
        return renderer.uiImage
    }
}
