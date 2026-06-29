//
//  AppDIContainer+Chat.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation

extension AppDIContainer {

    func makeChatRemoteDataSource() -> ChatRemoteDataSource {
        MockChatRemoteDataSource()
    }

    func makeChatRepository() -> ChatRepositoryProtocol {
        ChatRepositoryImpl(remote: makeChatRemoteDataSource())
    }

    func makeLoadChatThreadUseCase() -> LoadChatThreadUseCase {
        LoadChatThreadUseCase(repository: makeChatRepository())
    }

    @MainActor
    func makeChatViewModel() -> ChatViewModel {
        ChatViewModel(loadChatThreadUseCase: makeLoadChatThreadUseCase())
    }
}
