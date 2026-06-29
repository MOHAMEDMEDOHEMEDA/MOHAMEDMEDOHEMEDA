//
//  PlaceItem.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import MapKit

// MARK: - Model
struct PlaceItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double

    init(mapItem: MKMapItem) {
        name = mapItem.name ?? "—"
        address = mapItem.placemark.title ?? ""
        latitude = mapItem.placemark.coordinate.latitude
        longitude = mapItem.placemark.coordinate.longitude
    }

    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
