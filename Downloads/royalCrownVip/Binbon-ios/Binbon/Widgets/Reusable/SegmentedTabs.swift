//
//  SegmentedTabs.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

struct SegmentedTabs: View {

    let titles: [String]
    @Binding var selection: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.appText.opacity(0.25))
                .frame(height: 1)

            HStack(spacing: 28) {
                ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                    let isSelected = index == selection
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selection = index }
                    } label: {
                        VStack(spacing: 6) {
                            Text(title)
                                .font(.subheadline.weight(isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .appText : .appText.opacity(0.6))

                            Capsule()
                                .fill(isSelected ? Color.appText : Color.clear)
                                .frame(height: 3)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SegmentedTabs(titles: ["Silver coins (games)", "Gold"], selection: .constant(1))
        .padding()
        .background(Color.black)
}
