//
//  CallAvatarImage.swift
//  Binbon
//

import SwiftUI

/// The contact avatar, loaded remotely when a URL is present and falling back to the
/// bundled asset otherwise. Shared by the call background and the single-caller hero.
struct CallAvatarImage: View {
    let avatarURL: String?
    let avatarAsset: String

    var body: some View {
        if let avatarURL {
            ImageView(avatarURL, placeholder: Image(avatarAsset))
        } else {
            Image(avatarAsset)
                .resizable()
                .scaledToFill()
        }
    }
}
