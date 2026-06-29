//
//  ExpandView.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import SwiftUI

// MARK: - Section Builder
struct SectionItem {
    let title: String
    let padding: Bool
    let content: AnyView
    /// When set, the row navigates on tap instead of expanding — content is
    /// ignored and the chevron stays pointed forward.
    let onTap: (() -> Void)?
}

// MARK: - Setting View
struct ExpandView: View {
    
    @State private var expandStates: [Bool]
    private let sections: [SectionItem]
    /// Repaints the header gradient live when the theme switches.
    @ObservedObject private var theme = ThemeManager.shared
    /// Rebuilds the list when the locale flips so section headers don't mirror stale RTL state.
    @ObservedObject private var localizer = Localizer.shared
    
    init(@SectionBuilder _ builder: () -> [SectionItem]) {
        let items = builder()
        self.sections = items
        _expandStates = State(initialValue: Array(repeating: false, count: items.count))
    }
    
    var body: some View {
        List {
            ForEach(sections.indices, id: \.self) { index in
                Section {
                    if sections[index].onTap == nil, expandStates[index] {
                        sections[index].content
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(sections[index].padding ? 16 : 0)
                    }
                } header: {
                    Button {
                        if let onTap = sections[index].onTap {
                            onTap()
                        } else {
                            withAnimation {
                                expandStates[index].toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text(sections[index].title)
                                .font(.headline)
                                .foregroundColor(.appText)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.appText)
                                .imageScale(.small)
                                .rotationEffect(.degrees(sections[index].onTap == nil && expandStates[index] ? 90 : 0))
                        }
                        .environment(\.layoutDirection, localizer.language.direction)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColor.chromeButtonGradient)
                        .cornerRadius(0)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .zIndex(1)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowSpacing(0)
                .listSectionSpacing(0)
            }
        }
        .padding(.bottom, 24)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.layoutDirection, localizer.language.direction)
        .id(localizer.language.rawValue)
        .clipped()
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Result Builder
@resultBuilder
struct SectionBuilder {
    static func buildBlock(_ components: SectionItem...) -> [SectionItem] {
        components
    }
}

// MARK: - Helper functions
func Section<Content: View>(_ title: String, padding: Bool = true, @ViewBuilder content: @escaping () -> Content) -> SectionItem {
    SectionItem(title: title, padding: padding, content: AnyView(content()), onTap: nil)
}

/// A non-expanding row that navigates on tap — used for sections whose detail
/// is rendered as a full-screen view rather than inline.
func Section(_ title: String, onTap: @escaping () -> Void) -> SectionItem {
    SectionItem(title: title, padding: false, content: AnyView(EmptyView()), onTap: onTap)
}
