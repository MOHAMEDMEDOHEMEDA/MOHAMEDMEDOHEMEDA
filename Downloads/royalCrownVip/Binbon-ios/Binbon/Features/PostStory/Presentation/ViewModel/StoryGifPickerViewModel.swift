//
//  StoryGifPickerViewModel.swift
//  Binbon
//

import Combine
import Foundation

@MainActor
final class StoryGifPickerViewModel: ObservableObject {

    @Published var query = ""
    @Published private(set) var items: [StoryGifItem] = []
    @Published var isLoading = false

    private let repo: StoryGifRepoProtocol

    init(repo: StoryGifRepoProtocol = StoryGifRepo()) {
        self.repo = repo
    }

    func loadTrending() async {
        isLoading = true
        defer { isLoading = false }

        switch await repo.trending() {
        case .success(let list):
            items = list
        case .failure:
            items = []
        }
    }

    func search() async {
        isLoading = true
        defer { isLoading = false }

        switch await repo.search(query: query) {
        case .success(let list):
            items = list
        case .failure:
            items = []
        }
    }
}
