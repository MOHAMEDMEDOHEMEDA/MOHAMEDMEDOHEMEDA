//
//  VideoCallSession.swift
//  Binbon
//

import Foundation

enum VideoCallTileAccent: Equatable {
    case remote
    case local
}

struct VideoCallParticipant: Identifiable, Equatable {
    let id: String
    let name: String
    let imageAsset: String
    let avatarURL: String?
    let accent: VideoCallTileAccent
    var isRaisedHand: Bool = false
    var activeReaction: String? = nil
    var isMuted: Bool = false
    var isOwner: Bool = false
}

struct VideoCallSession: Equatable {
    let durationText: String
    let participants: [VideoCallParticipant]
}
