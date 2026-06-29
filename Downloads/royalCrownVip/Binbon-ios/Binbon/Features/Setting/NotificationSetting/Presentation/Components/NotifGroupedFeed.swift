//
//  NotifGroupedFeed.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

protocol NotifGroupable: Identifiable {
    var group: NotifGroup { get }
}

struct NotifGroupedFeed<Item: NotifGroupable, Row: View>: View {
    let items: [Item]
    var headerAccessory: ((NotifGroup) -> AnyView?)? = nil
    var showDividers: Bool = true
    @ViewBuilder let row: (Item) -> Row

    private let groups: [NotifGroup] = [.today, .yesterday, .last7Days, .previously]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(groups, id: \.rawValue) { group in
                let groupItems = items.filter { $0.group == group }
                if !groupItems.isEmpty {
                    header(for: group)

                    ForEach(groupItems) { item in
                        row(item)
                        if showDividers {
                            NotifDivider()
                        }
                    }
                }
            }
        }
    }

    private func header(for group: NotifGroup) -> some View {
        HStack {
            Text(group.localized)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.appText)

            if let accessory = headerAccessory?(group) {
                Spacer()
                accessory
            }
        }
        .padding(.top, 4)
    }
}
