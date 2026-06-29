//
//  StoryTabsBar.swift
//  Binbon
//

import SwiftUI


struct StoryTabsBar: View {

    @Binding var selection: StoryTab
    let onSelect: (StoryTab) -> Void

    private let tabHeight: CGFloat = 38

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(StoryTab.allCases) { tab in
                    StoryFolderTab(
                        isSelected: selection == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) { onSelect(tab) }
                        },
                        label: {
                            Text(tab.titleKey.localized)
                                .font(.system(size: 13, weight: selection == tab ? .bold : .semibold))
                                .foregroundStyle(Color.appText)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: tabHeight)
    }
}
