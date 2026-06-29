//
//  ShareContact.swift
//  Binbon
//

import Foundation

// MARK: - Contacts
struct ShareContact: Identifiable, Equatable {
    let id: String
    let name: String
    let username: String
    let avatarURL: String
}

extension Array where Element == ShareContact {
    static var mock: [ShareContact] {
        [
            ShareContact(id: "1", name: "Amira Ali",    username: "noor90",   avatarURL: "https://i.pravatar.cc/150?img=31"),
            ShareContact(id: "2", name: "Eman Ezat",    username: "karim_22", avatarURL: "https://i.pravatar.cc/150?img=45"),
            ShareContact(id: "3", name: "Sara Mostafa", username: "sara_23",  avatarURL: "https://i.pravatar.cc/150?img=20"),
            ShareContact(id: "4", name: "Omar Adel",    username: "youssef",  avatarURL: "https://i.pravatar.cc/150?img=12"),
            ShareContact(id: "5", name: "Lina Hassan",  username: "dalia_a",  avatarURL: "https://i.pravatar.cc/150?img=9"),
            ShareContact(id: "6", name: "Youssef Tarek", username: "omar_1",  avatarURL: "https://i.pravatar.cc/150?img=33"),
            ShareContact(id: "7", name: "Nour Adham",   username: "farida",   avatarURL: "https://i.pravatar.cc/150?img=49"),
            ShareContact(id: "8", name: "Tamer Magdy",  username: "tamer_m",  avatarURL: "https://i.pravatar.cc/150?img=15"),
            ShareContact(id: "9", name: "Hana Saad",    username: "hana_s",   avatarURL: "https://i.pravatar.cc/150?img=5")
        ]
    }
}
