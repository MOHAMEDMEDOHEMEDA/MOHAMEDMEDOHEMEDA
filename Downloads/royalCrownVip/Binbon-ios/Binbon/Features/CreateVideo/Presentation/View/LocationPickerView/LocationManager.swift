//
//  LocationManager.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import CoreLocation
import UIKit

// MARK: - Location authorization + current fix
@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var status: CLAuthorizationStatus
    @Published var location: CLLocation?

    override init() {
        status = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var isAuthorized: Bool { status == .authorizedWhenInUse || status == .authorizedAlways }
    var isDenied: Bool { status == .denied || status == .restricted }

    func requestOrFetch() {
        switch status {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }

    func fetchIfAuthorized() {
        if isAuthorized { manager.requestLocation() }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.status = manager.authorizationStatus
            if self.isAuthorized { manager.requestLocation() }
        }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in self.location = locations.last }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
