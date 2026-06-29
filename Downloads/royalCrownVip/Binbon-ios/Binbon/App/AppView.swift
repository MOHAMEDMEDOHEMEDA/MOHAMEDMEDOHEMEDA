//
//  AppView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

@main
struct AppView: App {

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .theme()
                .toaster()
                .connectivity()
                .localizer()
        }
    }
}
