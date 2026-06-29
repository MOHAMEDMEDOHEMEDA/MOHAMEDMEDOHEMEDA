//
//  DropdownSelector.swift
//  Binbon
//
//  Created by Claude on 05/06/2026.
//

import SwiftUI


struct DropdownSelector<Option: DynamicOptionProtocol>: View {

    let options: [Option]
    @Binding var selection: Option
    var onSelectionChange: ((Option) -> Void)?
    var onExpandedChange: ((Bool) -> Void)?

    @State private var isExpanded = false

    init(options: [Option]? = nil,
         selection: Binding<Option>,
         onSelectionChange: ((Option) -> Void)? = nil,
         onExpandedChange: ((Bool) -> Void)? = nil) {
        self.options = options ?? Array(Option.allCases)
        self._selection = selection
        self.onSelectionChange = onSelectionChange
        self.onExpandedChange = onExpandedChange
    }

    var body: some View {
        collapsedBar
            .opacity(isExpanded ? 0 : 1)
            .overlay(alignment: .topTrailing) {
                if isExpanded {
                    expandedCard
                        .fixedSize()
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .topTrailing)))
                }
            }
            .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }

    // MARK: - Collapsed
    private var collapsedBar: some View {
        Button {
            setExpanded(true)
        } label: {
            HStack(spacing: 12) {
                Text(selection.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                triangle(up: false)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded
    private var expandedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                setExpanded(false)
            } label: {
                HStack(spacing: 12) {
                    Text(selection.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer(minLength: 16)

                    triangle(up: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            optionsList
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "83489C"), Color(hex: "EB7048")],
                                     startPoint: .top,
                                     endPoint: .bottom))
                .shadow(color: AppColor.authListRowShadowColor, radius: 8, x: 0, y: 4)
        )
    }

    private var optionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    select(option)
                } label: {
                    Text(option.title)
                        .font(.subheadline.weight(option == selection ? .bold : .regular))
                        .foregroundStyle(.white.opacity(option == selection ? 1 : 0.85))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func triangle(up: Bool) -> some View {
        Image(systemName: up ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
            .resizable()
            .presentationCornerRadius(2)
            .frame(width: 15, height: 12)
            .foregroundStyle(.white)
    }

    private func select(_ option: Option) {
        selection = option
        onSelectionChange?(option)
        setExpanded(false)
    }

    private func setExpanded(_ value: Bool) {
        isExpanded = value
        onExpandedChange?(value)
    }
}
