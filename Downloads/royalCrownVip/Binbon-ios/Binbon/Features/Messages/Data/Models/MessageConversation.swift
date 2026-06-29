//
//  MessageConversation.swift
//  Binbon
//
//  A row in the Messages list: the other party, the preview line shown under
//  their name, and what kind of preview it is (so a missed-call mark or a
//  "typing…" hint renders correctly). Placeholder sample data until the
//  messaging API ships.
//

import Foundation

/// What the preview line under a name represents — drives the small leading
/// indicator (missed-call ✗) and lets the view tint typing/unread states.
enum MessagePreviewKind: Equatable, Hashable {
    case text
    case missedVoiceCall
    case missedVideoCall
    case typing

    var showsMissedMark: Bool {
        self == .missedVoiceCall || self == .missedVideoCall
    }
}

struct MessageConversation: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    /// Last message / status line shown under the name.
    let preview: String
    let previewKind: MessagePreviewKind
    /// Remote avatar URL; nil falls back to an initial badge.
    let avatarURL: String?
    /// Local asset name for the avatar (e.g. the Binbon logo). Takes precedence
    /// over `avatarURL` when set — used for system contacts like the agent row.
    let avatarAsset: String?

    init(name: String,
         preview: String,
         previewKind: MessagePreviewKind = .text,
         avatarURL: String? = nil,
         avatarAsset: String? = nil,
         id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.preview = preview
        self.previewKind = previewKind
        self.avatarURL = avatarURL
        self.avatarAsset = avatarAsset
    }

    static let samples: [MessageConversation] = [
        MessageConversation(name: "أحمد", preview: "msg_preview_hi", avatarURL: "https://i.pravatar.cc/150?img=12"),
        MessageConversation(name: "سمير", preview: "msg_preview_how_are_you", avatarURL: "https://i.pravatar.cc/150?img=15"),
        MessageConversation(name: "عبدالرحمن", preview: "msg_preview_missed_voice", previewKind: .missedVoiceCall, avatarURL: "https://i.pravatar.cc/150?img=33"),
        MessageConversation(name: "نرمين", preview: "msg_preview_how_is_it", avatarURL: "https://i.pravatar.cc/150?img=45"),
        MessageConversation(name: "يزن", preview: "msg_preview_messages", avatarURL: "https://i.pravatar.cc/150?img=51"),
        MessageConversation(name: "سارة", preview: "msg_preview_missed_video", previewKind: .missedVideoCall, avatarURL: "https://i.pravatar.cc/150?img=47"),
        MessageConversation(name: "نورة", preview: "msg_preview_typing", previewKind: .typing, avatarURL: "https://i.pravatar.cc/150?img=49"),
        MessageConversation(name: "محمد", preview: "msg_preview_miss_you", avatarURL: "https://i.pravatar.cc/150?img=53"),
        MessageConversation(name: "سمير", preview: "msg_preview_how_are_you", avatarURL: "https://i.pravatar.cc/150?img=15"),
        MessageConversation(name: "عبدالرحمن", preview: "msg_preview_missed_voice", previewKind: .missedVoiceCall, avatarURL: "https://i.pravatar.cc/150?img=33"),
        MessageConversation(name: "نرمين", preview: "msg_preview_how_is_it", avatarURL: "https://i.pravatar.cc/150?img=45"),
        MessageConversation(name: "يزن", preview: "msg_preview_messages", avatarURL: "https://i.pravatar.cc/150?img=51"),
        MessageConversation(name: "سارة", preview: "msg_preview_missed_video", previewKind: .missedVideoCall, avatarURL: "https://i.pravatar.cc/150?img=47"),
        MessageConversation(name: "نورة", preview: "msg_preview_typing", previewKind: .typing, avatarURL: "https://i.pravatar.cc/150?img=49"),
        MessageConversation(name: "محمد", preview: "msg_preview_miss_you", avatarURL: "https://i.pravatar.cc/150?img=53"),
        MessageConversation(name: "أحمد", preview: "msg_preview_hi", avatarURL: "https://i.pravatar.cc/150?img=12"),
        MessageConversation(name: "سمير", preview: "msg_preview_how_are_you", avatarURL: "https://i.pravatar.cc/150?img=15"),
        MessageConversation(name: "عبدالرحمن", preview: "msg_preview_missed_voice", previewKind: .missedVoiceCall, avatarURL: "https://i.pravatar.cc/150?img=33"),
        MessageConversation(name: "نرمين", preview: "msg_preview_how_is_it", avatarURL: "https://i.pravatar.cc/150?img=45"),
        MessageConversation(name: "يزن", preview: "msg_preview_messages", avatarURL: "https://i.pravatar.cc/150?img=51"),
        MessageConversation(name: "سارة", preview: "msg_preview_missed_video", previewKind: .missedVideoCall, avatarURL: "https://i.pravatar.cc/150?img=47"),
        MessageConversation(name: "نورة", preview: "msg_preview_typing", previewKind: .typing, avatarURL: "https://i.pravatar.cc/150?img=49"),
        MessageConversation(name: "محمد", preview: "msg_preview_miss_you", avatarURL: "https://i.pravatar.cc/150?img=53")
        ,
        MessageConversation(name: "سمير", preview: "msg_preview_how_are_you", avatarURL: "https://i.pravatar.cc/150?img=15"),
        MessageConversation(name: "عبدالرحمن", preview: "msg_preview_missed_voice", previewKind: .missedVoiceCall, avatarURL: "https://i.pravatar.cc/150?img=33"),
        MessageConversation(name: "نرمين", preview: "msg_preview_how_is_it", avatarURL: "https://i.pravatar.cc/150?img=45"),
        MessageConversation(name: "يزن", preview: "msg_preview_messages", avatarURL: "https://i.pravatar.cc/150?img=51"),
        MessageConversation(name: "سارة", preview: "msg_preview_missed_video", previewKind: .missedVideoCall, avatarURL: "https://i.pravatar.cc/150?img=47"),
        MessageConversation(name: "نورة", preview: "msg_preview_typing", previewKind: .typing, avatarURL: "https://i.pravatar.cc/150?img=49"),
        MessageConversation(name: "محمد", preview: "msg_preview_miss_you", avatarURL: "https://i.pravatar.cc/150?img=53")
    ]

    /// The الإدارة (management) tab shows the official Binbon management contact,
    /// badged with the Binbon logo. Computed so the localized name follows
    /// language changes.
    static var managementSamples: [MessageConversation] {
        [
            MessageConversation(name: "messages_tab_management".localized,
                                preview: "msg_preview_hi",
                                avatarAsset: "message-management-logo")
        ]
    }

    /// The مجموعات (groups) tab shows the user's group chats.
    static let groupSamples: [MessageConversation] = [
        MessageConversation(name: "اخوتي", preview: "msg_preview_typing", previewKind: .typing, avatarURL: "https://i.pravatar.cc/150?img=20"),
        MessageConversation(name: "جروب العيلة", preview: "msg_preview_how_are_you", avatarURL: "https://i.pravatar.cc/150?img=24"),
        MessageConversation(name: "الشلة", preview: "msg_preview_messages", avatarURL: "https://i.pravatar.cc/150?img=30")
    ]
}
