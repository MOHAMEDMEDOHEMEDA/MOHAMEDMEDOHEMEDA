//
//  CreatorVIPView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorVIPView: View {

    var body: some View {
        VIPControlsList(onMembershipLevelTap: {
            // TODO: wire to Set VIP Membership Level screen when available
        })
    }
}

#Preview {
    CreatorVIPView()
        .padding()
}
