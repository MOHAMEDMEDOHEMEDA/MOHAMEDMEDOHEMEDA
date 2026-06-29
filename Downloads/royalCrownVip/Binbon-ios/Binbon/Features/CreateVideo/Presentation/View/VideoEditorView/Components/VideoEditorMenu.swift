//
//  VideoEditorMenu.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoEditorMenu: View {

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let action: () -> Void
    }

    let items: [Item]

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
            ForEach(items) { item in
                Button(action: item.action) {
                    HStack(spacing: 10) {
                        if !item.title.isEmpty {
                            Text(item.title)
                                .font(.system(size: 15, weight: .medium))
                        }
                        Image(systemName: item.icon)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 28)
                    }
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .padding(.vertical, 6)
                    .padding(.leading, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
