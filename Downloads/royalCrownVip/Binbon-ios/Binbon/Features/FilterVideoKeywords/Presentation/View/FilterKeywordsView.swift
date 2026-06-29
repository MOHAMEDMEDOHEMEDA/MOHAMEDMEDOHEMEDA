//
//  FilterKeywordsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI

struct FilterKeywordsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var path = NavigationPath()
    // @State private var keywords: [String] = []
    @State private var keywords: [FilterKeyword] = [
        FilterKeyword(
            text: "#ahmed_gad",
            filterFrom: ["You"]
        ),
        FilterKeyword(
            text: "#Filter From You",
            filterFrom: ["Aya", "Sara"]
        ),
        FilterKeyword(
            text: "#keyword_test",
            filterFrom: ["Ahmed"]
        )
    ]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if keywords.isEmpty {
                    emptyStateView
                } else {
                    keywordsListView
                }
                
                addKeywordButton
            }
            .adaptiveContentWidth()
            .appBackground()
            .sheetNavigation(
                title: "filter_video_keywords".localized,
                showClose: true,
                hideBackButton: true,
                onClose: { dismiss() }
            )
            .navigationDestination(for: FilterRoute.self) { route in
                switch route {
                case .addKeyword:
                    AddKeywordView()
                }
            }
        }
        .environment(\.fullDismiss) { dismiss() }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            Image("add-keyword")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("add_a_video_keyword".localized)
                .font(.system(size: 18, weight: .medium))
                .padding(.top, 40)
            
            Text("filter_keyword_description".localized)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Keywords List
    private var keywordsListView: some View {
        VStack(spacing: 0) {
            
            Text("filter_keyword_description".localized)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColor.secondaryTextColor)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)
                .padding(.top, 32)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(keywords) { keyword in
                        keywordRow(keyword)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
    }
    
    private func keywordRow(_ keyword: FilterKeyword) -> some View {
        HStack(spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(keyword.text)
                    .font(.system(size: 14, weight: .medium))
                
                Text("Filter From: \(keyword.filterFrom.joined(separator: ", "))")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.secondaryTextColor)
            }
            
            Spacer()
            
            Button {
                keywords.removeAll { $0.id == keyword.id }
            } label: {
                Image("recycle-bin")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.cardBackground)
        )
    }
    
    // MARK: - Add Button
    private var addKeywordButton: some View {
        Button {
            path.append(FilterRoute.addKeyword)
        } label: {
            Text("add_keyword".localized)
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    AppColor.accentRed,
                    in: RoundedRectangle(cornerRadius: 10)
                )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}


struct FilterKeyword: Identifiable {
    let id = UUID()
    let text: String
    let filterFrom: [String]
}

enum FilterRoute: Hashable {
    case addKeyword
}
