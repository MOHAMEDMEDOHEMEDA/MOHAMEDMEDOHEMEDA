//
//  LocationFetcher.swift
//  Binbon
//

import CoreLocation

/// One-shot current-location fetcher using CLLocationManager.
final class LocationFetcher: NSObject, CLLocationManagerDelegate {

    static let shared = LocationFetcher()

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // @MainActor ensures CLLocationManager calls happen on the main thread.
    // Without this, Swift hops to the cooperative thread pool for non-isolated
    // async functions and CLLocationManager silently drops all calls.
    @MainActor
    func fetch() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { [weak self] cont in
            guard let self else {
                cont.resume(throwing: NSError(domain: "LocationFetcher", code: -1))
                return
            }
            guard continuation == nil else {
                cont.resume(throwing: NSError(domain: "LocationFetcher", code: -2, userInfo: [NSLocalizedDescriptionKey: "Fetch already in progress"]))
                return
            }
            continuation = cont
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                cont.resume(throwing: NSError(domain: "LocationFetcher", code: -3, userInfo: [NSLocalizedDescriptionKey: "Location access denied"]))
                continuation = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if continuation != nil { manager.requestLocation() }
        case .denied, .restricted:
            continuation?.resume(throwing: NSError(domain: "LocationFetcher", code: -3))
            continuation = nil
        default:
            break
        }
    }
}
