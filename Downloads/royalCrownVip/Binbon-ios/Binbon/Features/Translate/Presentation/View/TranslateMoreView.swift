//
//  TranslateMoreView.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI

struct TranslateMoreView: View {
    
    @Environment(\.fullDismiss) private var fullDismiss
    @State private var textOnPosts: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("select_other_types_to_translate".localized)
                .font(.system(size: 14, weight: .regular))
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 18)
            
            
            HStack {
                Text("text_on_posts".localized)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Toggle("", isOn: $textOnPosts)
                    .labelsHidden()
                    .tint(.red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .adaptiveContentWidth()
        .appBackground()
        .sheetNavigation(
            title: "translate_more".localized,
            hideBackButton: false,
            onCancel: { fullDismiss?() }
        )
    }
}

#Preview {
    NavigationStack {
        TranslateMoreView()
    }
}
