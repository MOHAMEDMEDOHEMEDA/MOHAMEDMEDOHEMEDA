//
//  StoryGifURLResolver.swift
//  Binbon
//

import Foundation

enum StoryGifURLResolver {

    private static let bundlePrefix = "bundle:"

    static func bundleReference(name: String) -> String {
        "\(bundlePrefix)\(name)"
    }

    static func url(from reference: String) -> URL? {
        if reference.hasPrefix(bundlePrefix) {
            let name = String(reference.dropFirst(bundlePrefix.count))
            return bundleURL(named: name)
        }
        return URL(string: reference)
    }

    static func bundleURL(named name: String) -> URL? {
        let candidates = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: nil) ?? []
        if let match = candidates.first(where: { $0.deletingPathExtension().lastPathComponent == name }) {
            return match
        }

        let subdirectories = [
            "Features/PostStory/Resources",
            "PostStory/Resources",
        ]

        for subdirectory in subdirectories {
            if let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: subdirectory) {
                return url
            }
        }

        return Bundle.main.url(forResource: name, withExtension: "gif")
    }
}
