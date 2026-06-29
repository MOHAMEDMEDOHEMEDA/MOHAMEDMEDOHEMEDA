//
//  LiveStreamSubviews.swift
//  Binbon
//
//  Created by Aya Mashaly on 04/06/2026.
//

import SwiftUI

struct InlineTextSelector<Option: DynamicOptionProtocol>: View {

    let options: [Option]
    @Binding var selection: Option
    var onSelectionChange: ((Option) -> Void)?

    init(options: [Option]? = nil,
         selection: Binding<Option>,
         onSelectionChange: ((Option) -> Void)? = nil) {
        self.options = options ?? Array(Option.allCases)
        self._selection = selection
        self.onSelectionChange = onSelectionChange
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                    onSelectionChange?(option)
                } label: {
                    Text(option.title)
                        .font(.footnote.weight(selection == option ? .bold : .medium))
                        .underline(selection == option, color: .white)
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Text("/")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppColor.secondaryTextColor)
                }
            }
        }
    }
}

struct LiveStreamControlsList: View {
    @ObservedObject var viewModel: LiveStreamSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Text("who_can_watch_live".localized)
                    .font(.footnote.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                DynamicSelector(selection: $viewModel.liveVisibility)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DynamicSelector(selection: $viewModel.liveType)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Text("allow_or_disable_comments".localized)
                    .font(.footnote.weight(.semibold))

                Spacer()

                InlineTextSelector(selection: $viewModel.commentsAllowance)
            }
        }
        .padding(.top, 4)
    }
}
