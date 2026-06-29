//
//  ExpandableCaption.swift
//  Binbon
//

import SwiftUI

// MARK: - Expandable caption

struct ExpandableCaption: View {
    let author: String
    let caption: String

    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var singleLineHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0

    private var styledText: Text {
        Text(author).font(.system(size: 13, weight: .bold))
        + Text(" ")
        + Text(caption).font(.system(size: 13, weight: .light))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isExpanded {
                styledText
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                toggle("show_less")
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    styledText
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if isTruncated {
                        toggle("show_more")
                            .fixedSize()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(truncationProbe)
    }

    private func toggle(_ key: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        } label: {
            Text(key.localized)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.captionMuted)
        }
        .buttonStyle(.plain)
    }

    private var truncationProbe: some View {
        ZStack(alignment: .topLeading) {
            styledText
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: SingleLineHeightKey.self, value: geo.size.height)
                })
            styledText
                .fixedSize(horizontal: false, vertical: true)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: FullHeightKey.self, value: geo.size.height)
                })
        }
        .hidden()
        .allowsHitTesting(false)
        .onPreferenceChange(SingleLineHeightKey.self) { singleLineHeight = $0; updateTruncated() }
        .onPreferenceChange(FullHeightKey.self) { fullHeight = $0; updateTruncated() }
    }

    private func updateTruncated() {
        guard singleLineHeight > 0, fullHeight > 0 else { return }
        isTruncated = fullHeight > singleLineHeight + 1
    }
}

private struct SingleLineHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

private struct FullHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}
