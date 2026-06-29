//
//  NotifSoundRow.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifSoundRow: View {
    let title: String
    let value: String?
    let options: [String]
    let onSelect: (String) -> Void

    @State private var showOptions = false
    private var hasValue: Bool { value?.isEmpty == false }

    var body: some View {
        Button {
            showOptions = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)

                Text(hasValue ? value! : "select".localized)
                    .font(.footnote)
                    .foregroundStyle(hasValue ? Color.appGold : .appText.opacity(0.5))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(options.isEmpty)
        .padding(.vertical, 12)
        .confirmationDialog(title, isPresented: $showOptions, titleVisibility: .visible) {
            ForEach(options, id: \.self) { option in
                Button(option) { onSelect(option) }
            }
        }
    }
}
