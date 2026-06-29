//
//  CallContact.swift
//  Binbon
//

import Foundation

struct CallContact: Identifiable, Equatable {
    let id: String
    let displayName: String
    let avatarURL: String?
}

extension CallContact {
    static let mockList: [CallContact] = [
        CallContact(id: "c1", displayName: "سمير",       avatarURL: "https://picsum.photos/seed/c1/200"),
        CallContact(id: "c2", displayName: "عبدالرحمن", avatarURL: "https://picsum.photos/seed/c2/200"),
        CallContact(id: "c3", displayName: "نرمين",      avatarURL: "https://picsum.photos/seed/c3/200"),
        CallContact(id: "c4", displayName: "يزن",        avatarURL: "https://picsum.photos/seed/c4/200"),
        CallContact(id: "c5", displayName: "سارة",       avatarURL: "https://picsum.photos/seed/c5/200"),
        CallContact(id: "c6", displayName: "نورة",       avatarURL: "https://picsum.photos/seed/c6/200"),
        CallContact(id: "c7", displayName: "محمد",       avatarURL: "https://picsum.photos/seed/c7/200"),
    ]
}
