//
//  Binbon + Image.swift
//  Binbon
//
//  Created by Salah Khaled on 12/03/2026.
//

import SwiftUI
import Combine

// MARK: - Network Image
extension Network {
    // Isolated to the main actor so all reads/writes of `imageCache` and
    // `inflightImages` happen on one thread. These are plain Dictionaries and the
    // method is called concurrently from many places (per-tile `.task`s, TaskGroups),
    // so unsynchronized access would corrupt the storage and hang the app. The heavy
    // work (`session.data`) is an `await` that releases the main thread.
    @MainActor
    func image(_ urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        if let cached = imageCache[url] { return cached }

        // If a fetch for this URL is already running, await its result instead of
        // starting a duplicate URLSession request (cache stampede guard).
        if let inflight = inflightImages[url] {
            return await inflight.value
        }

        let task = Task<UIImage?, Never> { @MainActor [weak self] in
            guard let self else { return nil }
            let start = Date()
            do {
                // Short timeout so an unreachable host fails fast.
                let request = URLRequest(url: url, timeoutInterval: 10)
                let (data, _) = try await session.data(for: request)
                let elapsed = Date().timeIntervalSince(start)
                let image = UIImage(data: data)
                if let img = image { imageCache[url] = img }
                Console.logImage(url: url, data: data, elapsed: elapsed)
                return image
            } catch {
                let elapsed = Date().timeIntervalSince(start)
                Console.logImage(url: url, data: nil, error: error, elapsed: elapsed)
                return nil
            }
        }

        inflightImages[url] = task
        let result = await task.value
        inflightImages.removeValue(forKey: url)
        return result
    }
}


// MARK: - Image View
struct ImageView: View {
    
    // MARK: - State
    @State private var image: UIImage?
    @State private var isLoading = true
    
    // MARK: - Properties
    let urlString: String?
    let loadingView: AnyView
    let holderView: Image
    /// When set, the loaded image is drawn as a template tinted with this
    /// color — pass a theme-adaptive color (e.g. `.appText`) to recolor a
    /// remote monochrome icon per theme.
    let tint: Color?

    // MARK: - Private
    private let defaultHolder = Image(systemName: "exclamationmark.circle")
    private let defaultLoading = AnyView(ProgressView().tint(.appText))

    /// Bundled photos used as offline placeholders during the mock-data phase.
    /// Picked deterministically per URL so each item keeps a stable image even
    /// when its remote host is unreachable.
    private static let mockPlaceholders = [
        "media-photo-1", "media-photo-2", "media-photo-3",
        "media-reel-1", "media-reel-2", "media-reel-3"
    ]

    private static func localPlaceholder(for key: String) -> UIImage? {
        guard !mockPlaceholders.isEmpty else { return nil }
        // Stable (launch-independent) hash so the same URL maps to the same asset.
        var hash: UInt64 = 5381
        for byte in key.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        let name = mockPlaceholders[Int(hash % UInt64(mockPlaceholders.count))]
        return UIImage(named: name)
    }

    // MARK: - Init
    init(_ url: String?, loading: AnyView? = nil, placeholder: Image? = nil, tint: Color? = nil) {
        self.urlString = url
        self.loadingView = loading ?? defaultLoading
        self.holderView = placeholder ?? defaultHolder
        self.tint = tint
    }

    // MARK: - View
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .renderingMode(tint == nil ? .original : .template)
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(tint ?? .primary)
            } else if isLoading {
                loadingView
            } else {
                holderView
                    .renderingMode(.template)
                    .font(.title)
//                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.primary)
            }
        }
        .task(id: urlString) {
            await load()
        }
    }
    
    // MARK: - Load
    @MainActor
    private func load() async {
        guard let urlString, !urlString.isEmpty else {
            image = nil
            isLoading = false
            return
        }

        // Bare asset name (mock data) → load straight from the asset catalog.
        if !urlString.lowercased().hasPrefix("http") {
            image = UIImage(named: urlString)
            isLoading = false
            return
        }

        // Hot path: image already cached — apply without blanking the current image or
        // showing a spinner. Handles the common case where SwiftUI re-fires .task
        // because a grid layout change shifted this view's structural identity, even
        // though the URL itself hasn't changed.
        if let url = URL(string: urlString), let cached = Network.shared.imageCache[url] {
            image = cached
            isLoading = false
            return
        }

        // Cold path: show a stable local placeholder while the network fetch runs.
        image = Self.localPlaceholder(for: urlString)
        isLoading = false

        if let remote = await Network.shared.image(urlString) {
            image = remote
        }
    }
}
