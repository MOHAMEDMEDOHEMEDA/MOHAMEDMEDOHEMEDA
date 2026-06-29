//
//  GamePeriodMenu.swift
//  Binbon
//
//  Header row for the achievements feed: the active date on the leading
//  side, a period dropdown on the trailing side (mirrors in RTL).
//
//  Uses a Button + confirmationDialog (the codebase's in-List dropdown
//  pattern, see NotifSoundRow) instead of a SwiftUI `Menu`, which triggers
//  the "_UIReparentingView" warning when embedded in a List/ExpandView.
//

import SwiftUI

struct GamePeriodMenu: View {
    @Binding var selection: GamePeriod
    let dateText: String

    @State private var showOptions = false

    var body: some View {
        HStack {
            Text(dateText)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.appText)

            Spacer()

            Button {
                showOptions = true
            } label: {
                HStack(spacing: 4) {
                    Text(selection.title)
                        .font(.footnote.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                }
                .foregroundStyle(.appText)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .confirmationDialog("period_last_week".localized,
                            isPresented: $showOptions,
                            titleVisibility: .hidden) {
            ForEach(GamePeriod.allCases) { period in
                Button(period.title) { selection = period }
            }
        }
    }
}
