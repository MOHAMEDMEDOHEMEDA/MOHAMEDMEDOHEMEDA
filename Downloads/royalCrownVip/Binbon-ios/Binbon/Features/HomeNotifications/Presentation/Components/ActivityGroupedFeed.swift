//
//  ActivityGroupedFeed.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityGroupedFeed<Row: View>: View {
    let items: [ActivityItem]
    @ViewBuilder let row: (ActivityItem) -> Row

    private let sections: [ActivitySection] = [.today, .yesterday, .thisWeek, .previously]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sections, id: \.rawValue) { section in
                let sectionItems = items.filter { $0.section == section }
                if !sectionItems.isEmpty {
                    Text(section.localized)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.appText)

                    ForEach(sectionItems) { item in
                        row(item)
                    }
                }
            }
        }
    }
}
