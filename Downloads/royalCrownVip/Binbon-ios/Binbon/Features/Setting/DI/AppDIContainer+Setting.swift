//
//  AppDIContainer+Setting.swift
//  Binbon
//
//  Composition root — shared Settings infrastructure. The existing `SettingRepo`
//  is the settings data source; each Setting sub-feature wraps it behind its own
//  domain repository (see `AppDIContainer+<SubFeature>`). When every sub-feature is
//  migrated, `SettingRepo` can be renamed to a proper remote data source.
//

import Foundation

extension AppDIContainer {

    /// Shared settings data source backing every Setting sub-feature repository.
    func makeSettingRepo() -> SettingRepoProtocol {
        SettingRepo()
    }
}
