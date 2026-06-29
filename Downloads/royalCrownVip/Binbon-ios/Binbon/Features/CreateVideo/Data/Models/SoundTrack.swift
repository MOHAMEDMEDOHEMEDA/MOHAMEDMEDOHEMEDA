//
//  SoundTrack.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Foundation

struct SoundTrack: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let duration: String
    let posts: String
    let fileName: String?

    init(title: String, artist: String, duration: String, posts: String = "0", fileName: String? = nil) {
        self.title = title
        self.artist = artist
        self.duration = duration
        self.posts = posts
        self.fileName = fileName
    }

    static let samples: [SoundTrack] = [
        SoundTrack(title: "Sunset Drive", artist: "Binbon Music", duration: "0:20", posts: "4032",  fileName: "sunset_drive"),
        SoundTrack(title: "Neon Nights",  artist: "Aria",         duration: "0:20", posts: "21.4K", fileName: "neon_nights"),
        SoundTrack(title: "Golden Hour",  artist: "L. Hadid",     duration: "0:20", posts: "537",   fileName: "golden_hour"),
        SoundTrack(title: "Soft Focus",   artist: "Binbon Music", duration: "0:20", posts: "37.0K", fileName: "soft_focus"),
        SoundTrack(title: "City Pulse",   artist: "Karim",        duration: "0:20", posts: "6156",  fileName: "city_pulse"),
        SoundTrack(title: "Daydream",     artist: "Mira",         duration: "0:20", posts: "1684",  fileName: "daydream")
    ]
}
