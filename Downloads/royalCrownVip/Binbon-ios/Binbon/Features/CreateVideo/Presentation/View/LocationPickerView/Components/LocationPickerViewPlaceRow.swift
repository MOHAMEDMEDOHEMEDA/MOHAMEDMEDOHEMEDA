//
//  LocationPickerViewPlaceRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct LocationPickerViewPlaceRow: View {

    let place: PlaceItem
    var onSelect: (PlaceItem) -> Void = { _ in }
    var onClose: () -> Void = {}

    var body: some View {
        Button {
            onSelect(place)
            onClose()
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.appText)
                if !place.address.isEmpty {
                    Text(place.address)
                        .font(.system(size: 13))
                        .foregroundStyle(.appText.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
