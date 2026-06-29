//
//  ShortModel.swift
//  Binbon
//
//  A short video in the Shorts feed. Engagement counts are kept as preformatted
//  display strings (e.g. "182K", "2,910") so the UI matches the design exactly
//  until the API supplies real numbers. Placeholder data during the UI-only phase.
//

import Foundation

struct ShortModel: Identifiable, Equatable {
    let id: String
    let videoURL: URL
    /// Handle shown as "@author".
    let author: String
    let authorAvatarURL: String?
    let caption: String
    /// Mentions + hashtags line, rendered in the accent color.
    let tags: String
    /// Sound attribution shown under the caption ("title · artist").
    let soundTitle: String
    let soundArtist: String
    let soundAvatarURL: String?
    let viewsText: String
    let likesText: String
    let commentsText: String
    let sharesText: String
}
