//
//  StoryEditorToolRail.swift
//  Binbon
//

import SwiftUI

struct StoryEditorToolRail: View {

    struct Item: Identifiable {
        let id: String
        let icon: String
        let action: () -> Void

        init(id: String? = nil, icon: String, action: @escaping () -> Void) {
            self.id = id ?? icon
            self.icon = icon
            self.action = action
        }
    }

    let primaryItems: [Item]
    let expandedItems: [Item]
    @Binding var isExpanded: Bool

    init(
        primaryItems: [Item],
        expandedItems: [Item],
        isExpanded: Binding<Bool> = .constant(false)
    ) {
        self.primaryItems = primaryItems
        self.expandedItems = expandedItems
        _isExpanded = isExpanded
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
            ForEach(visibleItems) { item in
                Button(action: item.action) {
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 3)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if !expandedItems.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white.opacity(0.9))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var visibleItems: [Item] {
        isExpanded ? primaryItems + expandedItems : primaryItems
    }
}
