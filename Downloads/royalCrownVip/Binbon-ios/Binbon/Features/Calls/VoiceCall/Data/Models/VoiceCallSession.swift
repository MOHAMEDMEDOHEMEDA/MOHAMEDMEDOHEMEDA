//
//  VoiceCallSession.swift
//  Binbon
//

import Foundation

/// Initial state of a voice call: the contact being called plus whether this
/// call is meant to ring and then promote itself to a video call.
struct VoiceCallSession: Equatable {
    let primaryParticipant: CallParticipant
    let transitionsToVideo: Bool
}
