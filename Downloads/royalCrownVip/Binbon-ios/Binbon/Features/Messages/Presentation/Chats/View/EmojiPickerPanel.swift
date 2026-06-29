//
//  EmojiPickerPanel.swift
//  Binbon
//

import SwiftUI

struct EmojiPickerPanel: View {

    @Binding var composerText: String
    @State private var searchText = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 5)

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(filteredEmojis, id: \.self) { emoji in
                        Button {
                            composerText += emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 38))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color(red: 0.12, green: 0.10, blue: 0.14))
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 20,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 20,
            style: .continuous
        ))
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("", text: $searchText, prompt:
                Text("emoji_search_placeholder".localized).foregroundColor(.white.opacity(0.4)))
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .autocorrectionDisabled()

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 15, weight: .medium))
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Data

    private var filteredEmojis: [String] {
        guard !searchText.isEmpty else { return Self.allEmojis }
        let query = searchText.lowercased()
        return Self.allEmojis.filter { emoji in
            emoji.unicodeScalars.contains { scalar in
                (scalar.properties.name ?? "").lowercased().contains(query)
            }
        }
    }

    static let allEmojis: [String] = [
        // Smileys & expressions
        "😀", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂",
        "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋",
        "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐",
        "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😔",
        "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵",
        "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐",
        "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦",
        "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞",
        "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿",
        "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖",
        // Gestures & hands
        "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "✌️", "🤞", "🤟",
        "🤘", "🤙", "👈", "👉", "👆", "👇", "☝️", "👍", "👎", "✊",
        "👊", "🤛", "🤜", "👏", "🙌", "🤝", "🙏", "✍️", "💪", "💅",
        // Hearts & symbols
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔",
        "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟",
        // Nature & weather
        "🌟", "⭐", "🌙", "☀️", "🌈", "⚡", "❄️", "🔥", "💧", "🌊",
        "🌸", "🌺", "🌻", "🌹", "🥀", "🌷", "🍀", "🌿", "🍃", "🌴",
        // Food & drink
        "🍕", "🍔", "🌮", "🍜", "🍣", "🍦", "🎂", "🍰", "☕", "🧋",
        "🍎", "🍊", "🍋", "🍇", "🍓", "🍒", "🥑", "🌶️", "🥕", "🍩",
        // Animals
        "🐱", "🐶", "🐭", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁",
        "🐮", "🐷", "🐸", "🐵", "🙈", "🙉", "🙊", "🦋", "🐝", "🦄",
        // Activities & objects
        "🎉", "🎊", "🎈", "🎁", "🎀", "🏆", "🥇", "✨", "💫", "💥",
        "🎵", "🎶", "🎸", "🎮", "⚽", "🏀", "🎯", "🚀", "✈️", "🚗",
        // Misc symbols
        "💯", "✅", "❌", "❓", "❗", "💬", "💭", "👑", "💎", "🔑",
        "📱", "💻", "📷", "🌍", "🏠", "🎪", "🎭", "🎨", "📚", "💡"
    ]
}
