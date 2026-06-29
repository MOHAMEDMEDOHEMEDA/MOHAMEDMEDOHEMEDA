//
//  CreateVideoViewPublishRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewPublishRow: View {

    @ObservedObject var viewModel: CreateVideoViewModel

    var body: some View {
        HStack(spacing: 8) {
            Button { viewModel.showShareSheet = true } label: {
                HStack(spacing: 7) {
                    CreateVideoViewStoryAvatar(image: viewModel.thumbnailImage)
                    Text("your_story".localized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 43)
                .background(Color(hex: "262626"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button { viewModel.showPostDetails = true } label: {
                Text("next".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 43)
                    .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 27)
    }
}
