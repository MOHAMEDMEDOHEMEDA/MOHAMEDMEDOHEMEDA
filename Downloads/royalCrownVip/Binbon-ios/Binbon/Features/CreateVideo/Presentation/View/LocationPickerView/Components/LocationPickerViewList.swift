//
//  LocationPickerViewList.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct LocationPickerViewList: View {

    @ObservedObject var vm: LocationSearchViewModel
    var onSelect: (PlaceItem) -> Void = { _ in }
    var onClose: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 18) {
                if vm.showingResults {
                    if vm.isSearching && vm.results.isEmpty {
                        ProgressView().tint(.appText).frame(maxWidth: .infinity)
                    }
                    ForEach(vm.results) { place in
                        LocationPickerViewPlaceRow(place: place, onSelect: onSelect, onClose: onClose)
                    }
                } else {
                    if !vm.nearby.isEmpty {
                        Text("popular_places_nearby".localized)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                    ForEach(vm.nearby) { place in
                        LocationPickerViewPlaceRow(place: place, onSelect: onSelect, onClose: onClose)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
