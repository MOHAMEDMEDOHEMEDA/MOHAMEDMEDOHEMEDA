//
//  LocationSearchViewModel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import MapKit

// MARK: - Search (MapKit)
@MainActor
final class LocationSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var nearby: [PlaceItem] = []
    @Published var results: [PlaceItem] = []
    @Published var isSearching = false

    private var searchTask: Task<Void, Never>?

    var showingResults: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    func loadNearby(around center: CLLocationCoordinate2D) async {
        let request = MKLocalPointsOfInterestRequest(center: center, radius: 5000)
        if let response = try? await MKLocalSearch(request: request).start() {
            nearby = response.mapItems.map(PlaceItem.init)
        }
    }

    func search(near center: CLLocationCoordinate2D?) {
        searchTask?.cancel()
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { results = []; isSearching = false; return }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            isSearching = true
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            if let center {
                request.region = MKCoordinateRegion(center: center,
                                                    latitudinalMeters: 30000,
                                                    longitudinalMeters: 30000)
            }
            let response = try? await MKLocalSearch(request: request).start()
            if Task.isCancelled { return }
            results = response?.mapItems.map(PlaceItem.init) ?? []
            isSearching = false
        }
    }
}
