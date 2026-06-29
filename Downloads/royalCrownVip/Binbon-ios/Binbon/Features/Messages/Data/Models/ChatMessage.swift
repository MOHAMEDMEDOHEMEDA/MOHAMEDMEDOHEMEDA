//
//  ChatMessage.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation
import CoreGraphics

enum ChatMessageSender: Equatable, Hashable {
    case me
    case other
}

enum ChatMessageKind: Equatable, Hashable {
    case text
    case missedVoiceCall
    case missedVideoCall
    case voice(url: URL, samples: [CGFloat], duration: Int)
    case pinNotification
    case images([Data], caption: String)
    case sticker(emoji: String, caption: String)
    case location(latitude: Double, longitude: Double, name: String)
    case document(name: String, size: String, url: URL)
    case audio(url: URL, duration: Int)
    case iconSticker(named: String)
    case video(url: URL, thumbnail: Data, caption: String)
    case media(images: [Data], videoURL: URL, videoThumbnail: Data, caption: String)
    case contact(name: String, phone: String)
}

struct ChatReplyInfo: Equatable, Hashable {
    let messageId: UUID
    let sender: ChatMessageSender
    let previewText: String
}

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id: UUID
    let sender: ChatMessageSender
    let kind: ChatMessageKind
    let text: String
    let time: String
    let isLiked: Bool
    var reaction: String?
    var isPinned: Bool
    var isStarred: Bool
    var replyTo: ChatReplyInfo?

    let daySeparator: String?

    init(sender: ChatMessageSender,
         kind: ChatMessageKind = .text,
         text: String = "",
         time: String,
         isLiked: Bool = false,
         reaction: String? = nil,
         isPinned: Bool = false,
         isStarred: Bool = false,
         replyTo: ChatReplyInfo? = nil,
         daySeparator: String? = nil,
         id: UUID = UUID()) {
        self.id = id
        self.sender = sender
        self.kind = kind
        self.text = text
        self.time = time
        self.isLiked = isLiked
        self.reaction = reaction
        self.isPinned = isPinned
        self.isStarred = isStarred
        self.replyTo = replyTo
        self.daySeparator = daySeparator
    }
}

extension ChatMessage {
    var pinPreviewText: String {
        switch kind {
        case .text:                         return text
        case .images(let items, let caption):
            return caption.isEmpty ? "chat_pin_preview_photo".localized : caption
        case .voice:                        return "chat_pin_preview_voice".localized
        case .audio:                        return "chat_pin_preview_audio".localized
        case .video(_, _, let caption):
            return caption.isEmpty ? "chat_pin_preview_video".localized : caption
        case .media(_, _, _, let caption):
            return caption.isEmpty ? "chat_pin_preview_media".localized : caption
        case .sticker(let emoji, _):        return emoji
        case .iconSticker:                  return "chat_pin_preview_sticker".localized
        case .document(let name, _, _):     return name
        case .location(_, _, let name):     return name
        case .contact(let name, _):             return name
        case .missedVoiceCall,
             .missedVideoCall,
             .pinNotification:             return text
        }
    }
}

struct ChatThread: Identifiable, Equatable, Hashable {
    let id: UUID
    let participantName: String
    let participantAvatarURL: String?
    let isVerified: Bool
    var messages: [ChatMessage]
 
    init(participantName: String,
         participantAvatarURL: String? = nil,
         isVerified: Bool = false,
         messages: [ChatMessage] = [],
         id: UUID = UUID()) {
        self.id = id
        self.participantName = participantName
        self.participantAvatarURL = participantAvatarURL
        self.isVerified = isVerified
        self.messages = messages
    }

    static let sample = ChatThread(
        participantName: "Samir Sameh",
        participantAvatarURL: "https://i.pravatar.cc/150?img=12",
        isVerified: true,
        messages: ChatMessage.samples
    )
}


struct ForwardContact: Identifiable {
    let id: UUID
    let name: String
    let avatarURL: String?

    static let frequent: [ForwardContact] = [
        ForwardContact(name: "أحمد",  avatarURL: "https://i.pravatar.cc/150?img=12"),
        ForwardContact(name: "محمد",  avatarURL: "https://i.pravatar.cc/150?img=14"),
        ForwardContact(name: "ياسر",  avatarURL: "https://i.pravatar.cc/150?img=17"),
        ForwardContact(name: "محمود", avatarURL: "https://i.pravatar.cc/150?img=22")
    ]

    static let recent: [ForwardContact] = [
        ForwardContact(name: "نورا",   avatarURL: "https://i.pravatar.cc/150?img=32"),
        ForwardContact(name: "يوسف",   avatarURL: "https://i.pravatar.cc/150?img=33"),
        ForwardContact(name: "حمزة",   avatarURL: "https://i.pravatar.cc/150?img=35"),
        ForwardContact(name: "جاسر",   avatarURL: "https://i.pravatar.cc/150?img=38"),
        ForwardContact(name: "ندى",    avatarURL: "https://i.pravatar.cc/150?img=44"),
        ForwardContact(name: "ممدوح",  avatarURL: "https://i.pravatar.cc/150?img=47"),
        ForwardContact(name: "سالي",   avatarURL: "https://i.pravatar.cc/150?img=49")
    ]

    init(name: String, avatarURL: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
    }
}

// MARK: - Sample thread (matches the Figma mock)

extension ChatMessage {
    static let samples: [ChatMessage] = [
        ChatMessage(sender: .other, kind: .missedVoiceCall, text: "chat_missed_voice_call".localized, time: "chat_time_1131".localized, daySeparator: "chat_day_june_10".localized),
        ChatMessage(sender: .other, kind: .missedVoiceCall, text: "chat_started_voice_call".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_hala_hamza".localized, time: "chat_time_1130".localized),
        ChatMessage(sender: .other, text: "chat_msg_hala_ahmed".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_alhamdulillah".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .other, text: "chat_msg_how_are_you".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_alhamdulillah_2".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, kind: .missedVideoCall, text: "chat_started_video_call".localized, time: "chat_time_1131".localized, daySeparator: "chat_day_june_12".localized),
        ChatMessage(sender: .me, kind: .missedVideoCall, text: "chat_started_video_call".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_you".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .other, kind: .missedVoiceCall, text: "chat_started_voice_call".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_hala_hamza".localized, time: "chat_time_1130".localized),
        ChatMessage(sender: .other, text: "chat_msg_hala_ahmed".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_alhamdulillah".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .other, text: "chat_msg_how_are_you".localized, time: "chat_time_1131".localized),
        ChatMessage(sender: .me, text: "chat_msg_alhamdulillah_2".localized, time: "chat_time_1131".localized),
    ]
}
