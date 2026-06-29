//
//  RegionLocationField.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.


import SwiftUI

struct RegionLocationField: View {

    let regionName: String?
    let onChange: () -> Void

    var body: some View {
        Button(action: onChange) {
            LanguageRegionFormField {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.85))
                        .frame(width: 24, height: 24)

                    Text(regionName ?? "select_location".localized)
                        .font(.subheadline)
                        .foregroundStyle(regionName == nil ? .appText.opacity(0.45) : .appText)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    Text("change".localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.appText)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RegionLocationField(regionName: nil, onChange: {})
        .padding()
        .appBackground()
}
