//
//  CaptionsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI
import Combine

class CaptionsViewModel: ObservableObject {
    @Published var showCaptions = false
    @Published var alwaysTranslatePosts = true
    @Published var selectedDoNotTranslate: [String] = ["English", "Arabic"]
    
    var doNotTranslateText: String {
        selectedDoNotTranslate.isEmpty ? "None" : selectedDoNotTranslate.joined(separator: ", ")
    }
    
    func toggleDoNotTranslate(_ lang: String) {
        if selectedDoNotTranslate.contains(lang) {
            selectedDoNotTranslate.removeAll { $0 == lang }
        } else {
            selectedDoNotTranslate.append(lang)
        }
    }
}
