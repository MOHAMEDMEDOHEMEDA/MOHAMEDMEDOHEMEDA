//
//  ContentCategory.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import Foundation

struct ContentCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
    }
}
