//
//  AppDIContainer+Messages.swift
//  Binbon
//
//  Composition root — Messages feature factories.
//

import Foundation

extension AppDIContainer {

    func makeMessagesRemoteDataSource() -> MessagesRemoteDataSource {
        MockMessagesRemoteDataSource()
    }

    func makeMessagesRepository() -> MessagesRepositoryProtocol {
        MessagesRepositoryImpl(remote: makeMessagesRemoteDataSource())
    }

    func makeLoadConversationsUseCase() -> LoadConversationsUseCase {
        LoadConversationsUseCase(repository: makeMessagesRepository())
    }

    @MainActor
    func makeMessagesViewModel() -> MessagesViewModel {
        MessagesViewModel(loadConversationsUseCase: makeLoadConversationsUseCase())
    }
}
