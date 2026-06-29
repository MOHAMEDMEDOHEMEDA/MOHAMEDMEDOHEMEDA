//
//  VideoEditorTextSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoEditorTextSheet: View {

    var initial: VideoOverlayItem?
    var onCancel: () -> Void = {}
    var onDone: (_ text: String, _ font: OverlayFont, _ size: CGFloat, _ colorHex: String) -> Void

    @State private var text: String
    @State private var font: OverlayFont
    @State private var size: CGFloat
    @State private var colorHex: String
    @FocusState private var focused: Bool

    init(initial: VideoOverlayItem? = nil,
         onCancel: @escaping () -> Void = {},
         onDone: @escaping (String, OverlayFont, CGFloat, String) -> Void) {
        self.initial = initial
        self.onCancel = onCancel
        self.onDone = onDone
        if case let .text(t, fontName, fontSize, hex)? = initial?.kind {
            _text = State(initialValue: t)
            _font = State(initialValue: OverlayFont(rawValue: fontName) ?? .system)
            _size = State(initialValue: fontSize)
            _colorHex = State(initialValue: hex)
        } else {
            _text = State(initialValue: "")
            _font = State(initialValue: .system)
            _size = State(initialValue: 34)
            _colorHex = State(initialValue: "FFFFFF")
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { commit() }

            VStack(spacing: 0) {
                HStack {
                    Button("cancel".localized) { onCancel() }.foregroundStyle(.white)
                    Spacer()
                    Button("done".localized) { commit() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                TextField("", text: $text, axis: .vertical)
                    .focused($focused)
                    .font(font.font(size: size))
                    .foregroundStyle(Color(hex: colorHex))
                    .multilineTextAlignment(.center)
                    .tint(.white)
                    .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 12) {
                    Image(systemName: "textformat.size.smaller").foregroundStyle(.white)
                    Slider(value: $size, in: 16...72)
                    Image(systemName: "textformat.size.larger").foregroundStyle(.white)
                }
                .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(OverlayFont.allCases) { f in
                            Button { font = f } label: {
                                Text("Aa")
                                    .font(f.font(size: 18))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 36)
                                    .background(font == f ? Color.white.opacity(0.25) : .clear,
                                                in: RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(OverlayPalette.hexes, id: \.self) { hex in
                            Button { colorHex = hex } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(.white, lineWidth: colorHex == hex ? 3 : 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 12)
            }
        }
        .onAppear { focused = true }
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { onCancel(); return }
        onDone(trimmed, font, size, colorHex)
    }
}
