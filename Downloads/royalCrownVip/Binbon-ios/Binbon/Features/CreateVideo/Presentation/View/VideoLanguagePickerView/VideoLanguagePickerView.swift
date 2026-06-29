//
//  VideoLanguagePickerView.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

enum VideoLanguage: String, CaseIterable, Identifiable {
    case english, arabic, french
    var id: String { rawValue }
    var title: String {
        switch self {
        case .english: return "lang_english".localized
        case .arabic:  return "lang_arabic".localized
        case .french:  return "lang_french".localized
        }
    }
}

struct VideoLanguagePickerView: View {

    @Binding var selected: VideoLanguage
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared
    private let accent = Color(hex: "E14554")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ForEach(VideoLanguage.allCases) { lang in
                    Button { selected = lang } label: {
                        HStack {
                            Text(lang.title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.appText)
                            Spacer()
                            PostSettingsSheetRadioDot(selected: selected == lang, accent: accent)
                        }
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .adaptiveContentWidth()
            .appBackground()
            .appNavigation(title: "select_languages".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.appText)
                    }
                }
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
    }
}
