//
//  AppDIContainer+Promote.swift
//  Binbon
//
//  Composition root — Promote feature factories.
//

import Foundation

extension AppDIContainer {

    @MainActor
    func makePromoteViewModel() -> PromoteViewModel {
        PromoteViewModel(settingRepo: makeSettingRepo())
    }
}
