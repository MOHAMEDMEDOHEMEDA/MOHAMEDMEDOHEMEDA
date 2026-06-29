//
//  PostDetailsViewLocationSection.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewLocationSection: View {

    @Binding var selectedLocation: String?
    let suggestedLocations: [String]
    var onPickLocation: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: onPickLocation) {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.appText)
                    Text(selectedLocation ?? "post_location".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(selectedLocation == nil ? .appText : Color(hex: "E14554"))
                    if selectedLocation == nil {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                    Spacer()
                    PostDetailsViewChevron()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestedLocations, id: \.self) { place in
                        Button { selectedLocation = place } label: {
                            Text(place)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedLocation == place ? .white : .appText)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(selectedLocation == place ? Color(hex: "E14554") : AppColor.cardBackground,
                                            in: RoundedRectangle(cornerRadius: 5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
