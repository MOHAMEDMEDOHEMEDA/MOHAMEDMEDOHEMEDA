//
//  StoryGifItem.swift
//  Binbon
//

import Foundation

struct StoryGifItem: Identifiable, Equatable {
    let id: String
    let title: String
    let previewURL: String
    let fullURL: String
    let previewAsset: String?

    init(
        id: String,
        title: String,
        previewURL: String,
        fullURL: String,
        previewAsset: String? = nil
    ) {
        self.id = id
        self.title = title
        self.previewURL = previewURL
        self.fullURL = fullURL
        self.previewAsset = previewAsset
    }
}
