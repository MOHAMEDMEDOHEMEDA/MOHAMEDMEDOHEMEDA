//
//  SoundsSheetTabBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

enum SoundsTab: String, CaseIterable, Identifiable {
    case hot, forYou, favorites, recent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hot:        return "snd_hot".localized
        case .forYou:     return "snd_for_you".localized
        case .favorites:  return "snd_favorites".localized
        case .recent:     return "snd_recent".localized
        }
    }
}

struct SoundsSheetTabBar: View {

    @Binding var selection: SoundsTab
    var onSearch: () -> Void = {}
    @Namespace private var underline

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SoundsTab.allCases) { tab in
                tabButton(tab)
            }
            Spacer(minLength: 8)
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.appText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func tabButton(_ tab: SoundsTab) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selection = tab }
        } label: {
            VStack(spacing: 6) {
                Text(tab.title)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color.appText : Color.appText.opacity(0.5))
                ZStack {
                    Capsule().fill(.clear).frame(height: 2)
                    if isSelected {
                        Capsule()
                            .fill(Color.appText)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "tab_underline", in: underline)
                    }
                }
            }
            .padding(.trailing, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
