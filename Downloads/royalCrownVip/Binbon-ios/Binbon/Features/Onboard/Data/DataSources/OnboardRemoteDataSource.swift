//
//  OnboardRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for onboarding. Backed by a mock during the
//  current pre-integration phase; swap in a network-backed source in the DI
//  factory when the API is ready.
//

import Foundation

protocol OnboardRemoteDataSource {
    func fetchSuggestions(step: OnboardStepEnum) async throws -> [OnboardSuggestionResponse]
    func followSelected(userIds: [Int]) async throws
    func followAll() async throws
    func complete(action: String) async throws
}

// MARK: - Mock

struct MockOnboardRemoteDataSource: OnboardRemoteDataSource {

    func fetchSuggestions(step: OnboardStepEnum) async throws -> [OnboardSuggestionResponse] {
        OnboardSuggestionResponse.dummy
    }

    func followSelected(userIds: [Int]) async throws {}
    func followAll() async throws {}
    func complete(action: String) async throws {}
}

private extension OnboardSuggestionResponse {
    static let dummy: [OnboardSuggestionResponse] = [
        OnboardSuggestionResponse(id: 2001, fullname: "Layla Hassan", username: "layla.h", profilePhoto: "https://picsum.photos/seed/2001/200", userEmail: "layla@example.com", bio: "Singer & performer", gender: "female"),
        OnboardSuggestionResponse(id: 2002, fullname: "Omar Adel", username: "omar.adel", profilePhoto: "https://picsum.photos/seed/2002/200", userEmail: "omar@example.com", bio: "Music producer", gender: "male"),
        OnboardSuggestionResponse(id: 2003, fullname: "Nour Ibrahim", username: "nour.i", profilePhoto: "https://picsum.photos/seed/2003/200", userEmail: "nour@example.com", bio: "Content creator", gender: "female"),
        OnboardSuggestionResponse(id: 2004, fullname: "Karim Fouad", username: "karim.f", profilePhoto: "https://picsum.photos/seed/2004/200", userEmail: "karim@example.com", bio: "Live host", gender: "male"),
        OnboardSuggestionResponse(id: 2005, fullname: "Salma Tarek", username: "salma.t", profilePhoto: "https://picsum.photos/seed/2005/200", userEmail: "salma@example.com", bio: "Dancer", gender: "female")
    ]
}
