//
//  SegmentedTabsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 07/06/2026.
//

import SwiftUI

struct SegmentedTabsView<Item: Identifiable>: View {
    let items: [Item]
    @Binding var selection: Item
    let title: (Item) -> String
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(items) { item in
                Button {
                    selection = item
                } label: {
                    Text(title(item))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 5)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                        .minimumScaleFactor(0.8)
                        .background {
                            Capsule()
                                .fill(AnyShapeStyle(LinearGradient(colors: [Color(hex: "#80408A"), Color(hex: "#EB7048")], startPoint: .leading, endPoint: .trailing)))
                                .overlay {
                                    Capsule()
                                        .stroke(Color(Color(hex: "#FBBC05")), lineWidth: 2)
                                }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
