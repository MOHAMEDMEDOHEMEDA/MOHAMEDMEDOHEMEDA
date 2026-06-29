//
//  AppDIContainer.swift
//  Binbon
//
//  Core — dependency injection. The application's composition root.
//

import Foundation

/// Composition root for the app and the single intentional singleton in the
/// codebase. Repositories, data sources, use cases and view models are assembled
/// here through per-feature factory extensions (see `AppDIContainer+<Feature>`),
/// so object creation is centralized rather than scattered across the layers.
///
/// Tests construct a private `AppDIContainer(storage:network:)` with fakes instead
/// of reaching for `.shared`.
final class AppDIContainer {

    /// Shared composition root used by the running app.
    static let shared = AppDIContainer()

    // MARK: - Shared infrastructure

    let storage: Storage
    let network: Network

    init(storage: Storage = .shared, network: Network = .shared) {
        self.storage = storage
        self.network = network
    }
}
