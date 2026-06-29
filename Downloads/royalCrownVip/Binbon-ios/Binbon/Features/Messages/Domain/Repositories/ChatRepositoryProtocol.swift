//
//  ChatRepositoryProtocol.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation

protocol ChatRepositoryProtocol {
    func loadThread() async throws -> ChatThread
}
