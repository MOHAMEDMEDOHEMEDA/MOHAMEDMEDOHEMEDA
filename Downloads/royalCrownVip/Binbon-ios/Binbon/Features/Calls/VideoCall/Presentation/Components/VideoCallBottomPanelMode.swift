//
//  VideoCallBottomPanelMode.swift
//  Binbon
//

import Foundation

/// Which panel occupies the bottom of the video call: the standard control dock, or one
/// of the effect strips (filters / backgrounds) that replaces it.
enum VideoCallBottomPanelMode: Equatable {
    case standard, filters, backgrounds
}
