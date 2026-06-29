//
//  LanguageRegionLanguageSheet.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.
//

import SwiftUI

// MARK: - Language sheet
 struct LanguageSheet: View {

    let current: Language
    let onSelect: (Language) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("select_language".localized)
                .font(.headline)
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(Language.allCases, id: \.rawValue) { language in
                    Button { onSelect(language) } label: {
                        HStack(spacing: 12) {
                            Text(language.flag)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.localizedName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.appText)
                                Text(language.nativeName)
                                    .font(.caption)
                                    .foregroundStyle(.appText.opacity(0.7))
                            }
                            Spacer()
                            if current == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColor.chromeButtonGradient)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Button(action: onDismiss) {
                Text("cancel".localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.appText.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.appText.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
    }
}
#Preview {
    LanguageSheet(current: .arabic, onSelect: {_ in }, onDismiss: {})
}
