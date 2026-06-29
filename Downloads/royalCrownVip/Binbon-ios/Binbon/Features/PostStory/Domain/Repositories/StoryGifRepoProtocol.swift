//
//  StoryGifRepoProtocol.swift
//  Binbon
//

import Foundation

protocol StoryGifRepoProtocol {
    func search(query: String) async -> Result<[StoryGifItem], APIError>
    func trending() async -> Result<[StoryGifItem], APIError>
}
