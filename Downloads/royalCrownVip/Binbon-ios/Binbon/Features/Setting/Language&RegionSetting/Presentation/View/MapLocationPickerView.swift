//
//  MapLocationPickerView.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.


import Combine
import CoreLocation
import MapKit
import SwiftUI

struct MapLocationPickerView: View {

    var onSelect: (PlaceItem) -> Void
    var onClose: () -> Void

    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchVM = LocationSearchViewModel()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var isConfirming = false
    @State private var didSetInitialCamera = false

    private let fieldInk = AppColor.promoteText
    private let fieldPlaceholder = Color.black.opacity(0.45)

    var body: some View {
        ZStack {
            mapLayer
            pinOverlay
            controlsOverlay
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            locationManager.fetchIfAuthorized()
            Task {
                try? await Task.sleep(nanoseconds: 600_000_000)
                guard !didSetInitialCamera else { return }
                didSetInitialCamera = true
                moveCamera(to: CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357))
            }
        }
        .onReceive(locationManager.$location.compactMap { $0 }) { location in
            guard !didSetInitialCamera else { return }
            didSetInitialCamera = true
            moveCamera(to: location.coordinate)
        }
        .onChange(of: searchVM.query) { searchVM.search(near: centerCoordinate) }
    }

    // MARK: - Map
    private var mapLayer: some View {
        Map(position: $cameraPosition, interactionModes: .all)
            .mapStyle(.standard(elevation: .realistic))
            .onMapCameraChange(frequency: .continuous) { context in
                centerCoordinate = context.region.center
            }
            .ignoresSafeArea()
    }

    private var pinOverlay: some View {
        Image(systemName: "mappin")
            .font(.system(size: 46))
            .fontWeight(.bold)
            .foregroundStyle(.red)
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            .allowsHitTesting(false)
    }

    // MARK: - Controls
    private var controlsOverlay: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if searchVM.showingResults {
                searchResults
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }

            Spacer()

            myLocationButton
                .padding(.trailing, 16)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text("move_the_map_to_select_location".localized)
                .font(.subheadline)
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            AppButton(title: "done".localized,
                      action: confirmSelection)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            MapCircleButton(systemName: "xmark", action: onClose)

            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    if searchVM.query.isEmpty {
                        Text("search_for_a_place".localized)
                            .font(.subheadline)
                            .foregroundStyle(fieldPlaceholder)
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $searchVM.query)
                        .font(.subheadline)
                        .foregroundStyle(fieldInk)
                        .tint(AppColor.accentRed)
                        .submitLabel(.search)
                        .onSubmit { searchVM.search(near: centerCoordinate) }
                }

                if !searchVM.query.isEmpty {
                    Button {
                        searchVM.query = ""
                        searchVM.results = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(fieldPlaceholder)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.coinTileBackground)
            )

            MapCircleButton(systemName: "magnifyingglass") {
                searchVM.search(near: centerCoordinate)
            }
        }
    }

    private var searchResults: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(searchVM.results) { place in
                    Button {
                        selectSearchResult(place)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(fieldInk)
                            if !place.address.isEmpty {
                                Text(place.address)
                                    .font(.caption)
                                    .foregroundStyle(fieldInk.opacity(0.65))
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)

                    Divider().overlay(fieldInk.opacity(0.12))
                }
            }
        }
        .frame(maxHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.coinTileBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var myLocationButton: some View {
        MapCircleButton(systemName: "location.fill") {
            locationManager.requestOrFetch()
            if let coordinate = locationManager.location?.coordinate {
                moveCamera(to: coordinate)
            }
        }
    }

    // MARK: - Actions
    private func moveCamera(to coordinate: CLLocationCoordinate2D) {
        centerCoordinate = coordinate
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 2_000,
                    longitudinalMeters: 2_000
                )
            )
        }
    }

    private func selectSearchResult(_ place: PlaceItem) {
        searchVM.query = place.name
        searchVM.results = []
        moveCamera(to: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
    }

    private func confirmSelection() {
        guard let coordinate = centerCoordinate, !isConfirming else { return }
        isConfirming = true

        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            let placemarks = (try? await geocoder.reverseGeocodeLocation(location)) ?? []
            let placemark = placemarks.first

            let name = placemark?.locality
                ?? placemark?.name
                ?? placemark?.administrativeArea
                ?? placemark?.country
                ?? "—"
            let address = [
                placemark?.thoroughfare,
                placemark?.locality,
                placemark?.administrativeArea,
                placemark?.country
            ]
            .compactMap { $0 }
            .joined(separator: ", ")

            let place = PlaceItem(
                name: name,
                address: address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            isConfirming = false
            onSelect(place)
        }
    }
}

// MARK: - Circle control
private struct MapCircleButton: View {

    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.purpleAsset))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MapLocationPickerView(onSelect: { _ in }, onClose: {})
}
