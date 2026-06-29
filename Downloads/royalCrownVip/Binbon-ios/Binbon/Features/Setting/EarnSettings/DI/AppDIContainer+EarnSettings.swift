//
//  AppDIContainer+EarnSettings.swift
//  Binbon
//
//  Composition root — EarnSettings sub-feature factories.
//

import Foundation

extension AppDIContainer {

    @MainActor
    func makePaymentAndProfitSettingsViewModel() -> PaymentAndProfitSettingsViewModel {
        PaymentAndProfitSettingsViewModel(settingRepo: makeSettingRepo())
    }
}
