//
//  StoryTextEditorSheet.swift
//  Binbon
//

import SwiftUI

struct StoryTextEditorSheet: View {

    var initialText: String = ""
    var initialFont: OverlayFont = .system
    var initialSize: CGFloat = 34
    var initialColorHex: String = "FFFFFF"
    var initialHasBackground: Bool = false
    var initialBackgroundHex: String = "E14554"
    var onCancel: () -> Void = {}
    var onDone: (_ text: String, _ font: OverlayFont, _ size: CGFloat, _ colorHex: String, _ hasBackground: Bool, _ backgroundHex: String) -> Void

    @State private var text: String
    @State private var font: OverlayFont
    @State private var size: CGFloat
    @State private var colorHex: String
    @State private var hasBackground: Bool
    @State private var backgroundHex: String
    @FocusState private var focused: Bool

    init(
        initialText: String = "",
        initialFont: OverlayFont = .system,
        initialSize: CGFloat = 34,
        initialColorHex: String = "FFFFFF",
        initialHasBackground: Bool = false,
        initialBackgroundHex: String = "E14554",
        onCancel: @escaping () -> Void = {},
        onDone: @escaping (String, OverlayFont, CGFloat, String, Bool, String) -> Void
    ) {
        self.initialText = initialText
        self.initialFont = initialFont
        self.initialSize = initialSize
        self.initialColorHex = initialColorHex
        self.initialHasBackground = initialHasBackground
        self.initialBackgroundHex = initialBackgroundHex
        self.onCancel = onCancel
        self.onDone = onDone
        _text = State(initialValue: initialText)
        _font = State(initialValue: initialFont)
        _size = State(initialValue: initialSize)
        _colorHex = State(initialValue: initialColorHex)
        _hasBackground = State(initialValue: initialHasBackground)
        _backgroundHex = State(initialValue: initialBackgroundHex)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                textPreview

                Spacer()

                fontStyles
                mentionSuggestions
                sizeSlider
                colorPalette
                backgroundControls
            }
        }
        .onAppear { focused = true }
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Button(action: { hasBackground.toggle() }) {
                Image(systemName: hasBackground ? "a.square.fill" : "a.square")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Circle()
                .fill(AngularGradient(colors: [.red, .yellow, .green, .blue, .purple, .red], center: .center))
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.white, lineWidth: 2))

            Button(action: { colorHex = "E14554" }) {
                Text("A")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(hex: "E14554"))
            }
            .buttonStyle(.plain)

            Image(systemName: "text.aligncenter")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button("done".localized, action: commit)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var textPreview: some View {
        TextField("", text: $text, axis: .vertical)
            .focused($focused)
            .font(font.font(size: size))
            .foregroundStyle(Color(hex: colorHex))
            .multilineTextAlignment(.center)
            .padding(.horizontal, hasBackground ? 14 : 0)
            .padding(.vertical, hasBackground ? 8 : 0)
            .background {
                if hasBackground {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: backgroundHex))
                }
            }
            .padding(.horizontal, 24)
    }

    private var fontStyles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(StoryFontStyle.allCases) { style in
                    Button { font = style.overlayFont } label: {
                        Text(style.title)
                            .font(style.overlayFont.font(size: 16))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().stroke(font == style.overlayFont ? Color.white : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
    }

    private var mentionSuggestions: some View {
        Group {
            if text.hasPrefix("@") {
                suggestionRow(StoryTextSuggestions.mentions) { value in
                    text = "@\(value)"
                }
            } else if text.hasPrefix("#") {
                suggestionRow(StoryTextSuggestions.hashtags) { value in
                    text = "#\(value)"
                }
            }
        }
    }

    private func suggestionRow(_ items: [String], onPick: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    Button { onPick(item) } label: {
                        Text(text.hasPrefix("#") ? "#\(item)" : "@\(item)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.15), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
    }

    private var sizeSlider: some View {
        HStack(spacing: 12) {
            Image(systemName: "textformat.size.smaller").foregroundStyle(.white)
            Slider(value: $size, in: 16...72)
            Image(systemName: "textformat.size.larger").foregroundStyle(.white)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var colorPalette: some View {
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

    private var backgroundControls: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(OverlayPalette.hexes, id: \.self) { hex in
                    Button { backgroundHex = hex } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(.white, lineWidth: backgroundHex == hex ? 2 : 0))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .opacity(hasBackground ? 1 : 0.35)
        .allowsHitTesting(hasBackground)
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { onCancel(); return }
        onDone(trimmed, font, size, colorHex, hasBackground, backgroundHex)
    }
}

enum StoryTextSuggestions {
    static let mentions = ["Amira ali", "Soltan Khames", "Dr.Hamzaofficial"]
    static let hashtags = ["Binbon", "Fitness", "Live"]
}

enum StoryFontStyle: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case elegance = "Elegance"
    case retro = "Retro"
    case vintage = "Vintage"

    var id: String { rawValue }

    var title: String { rawValue }

    var overlayFont: OverlayFont {
        switch self {
        case .classic: return .system
        case .elegance: return .serif
        case .retro: return .rounded
        case .vintage: return .mono
        }
    }
}
