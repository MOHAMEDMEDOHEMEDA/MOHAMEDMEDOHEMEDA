//
//  AppDIContainer+HelpAndSupport.swift
//  Binbon
//
//  Composition root — HelpAndSupport sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeHelpAndSupportRepository() -> HelpAndSupportRepositoryProtocol {
        HelpAndSupportRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchSupportFaqsUseCase() -> FetchSupportFaqsUseCase {
        FetchSupportFaqsUseCase(repository: makeHelpAndSupportRepository())
    }

    func makeSendSuggestionUseCase() -> SendSuggestionUseCase {
        SendSuggestionUseCase(repository: makeHelpAndSupportRepository())
    }

    func makeSendSupportReportUseCase() -> SendSupportReportUseCase {
        SendSupportReportUseCase(repository: makeHelpAndSupportRepository())
    }

    @MainActor
    func makeHelpAndSupportViewModel() -> HelpAndSupportViewModel {
        HelpAndSupportViewModel(
            fetchSupportFaqsUseCase: makeFetchSupportFaqsUseCase(),
            sendSuggestionUseCase: makeSendSuggestionUseCase(),
            sendReportUseCase: makeSendSupportReportUseCase()
        )
    }
}
