//
//  LocationPickerView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

// MARK: - View
struct LocationPickerView: View {

    var onSelect: (PlaceItem) -> Void = { _ in }
    var onClose: () -> Void = {}

    @StateObject private var location = LocationManager()
    @StateObject private var vm = LocationSearchViewModel()
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            LocationPickerViewTopBar(onClose: onClose)
            LocationPickerViewSearchField(query: $vm.query)
            if !location.isAuthorized {
                LocationPickerViewPermissionBanner(onEnable: location.requestOrFetch)
            }
            LocationPickerViewList(vm: vm, onSelect: onSelect, onClose: onClose)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .adaptiveContentWidth()
        .appBackground()
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { location.fetchIfAuthorized() }
        .onReceive(location.$location.compactMap { $0 }) { loc in
            Task { await vm.loadNearby(around: loc.coordinate) }
        }
        .onChange(of: vm.query) { vm.search(near: location.location?.coordinate) }
    }
}
