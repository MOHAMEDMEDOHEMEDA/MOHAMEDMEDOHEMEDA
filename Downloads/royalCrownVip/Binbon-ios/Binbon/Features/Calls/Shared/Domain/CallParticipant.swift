//
//  CallParticipant.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓲𝓮𝓷 on 23/06/2026.
//


import Foundation

struct CallParticipant: Identifiable, Equatable {
    let id: UUID
    let name: String
    let avatarURL: String?
    let avatarAsset: String
    var isRaisedHand: Bool = false
    var activeReaction: String? = nil
    var isMuted: Bool = false
    var isOwner: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        avatarURL: String? = nil,
        avatarAsset: String = "call-image",
        isOwner: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarAsset = avatarAsset
        self.isOwner = isOwner
    }

    init(conversation: MessageConversation) {
        self.id = conversation.id
        self.name = conversation.name
        self.avatarURL = conversation.avatarURL
        self.avatarAsset = "call-image"
    }
}
