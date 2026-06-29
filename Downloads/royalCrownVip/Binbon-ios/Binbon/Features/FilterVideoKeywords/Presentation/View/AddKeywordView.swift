//
//  AddKeywordView.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI

struct AddKeywordView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var keyword = ""
    @State private var filterForYou = false
    @State private var filterFollowing = false
    @Environment(\.fullDismiss) private var fullDismiss
    
    var onSave: ((String, [String]) -> Void)?
    
    private var isSaveEnabled: Bool {
        !keyword.trimmingCharacters(in: .whitespaces).isEmpty
        || filterForYou
        || filterFollowing
    }
    
    private var allSelected: Bool {
        filterForYou && filterFollowing
    }
    
    var body: some View {
        VStack(spacing: 28) {
            keywordInputView
            filterSectionView
            Spacer()
        }
        .adaptiveContentWidth()
        .appBackground()
        .sheetNavigation(
            title: "add_keyword".localized,
            showCancel: true,
            showSave: true,
            hideBackButton: true,
            isSaveEnabled: isSaveEnabled,
            onCancel: {
                fullDismiss?()
            },
            onSave: {
                var filters: [String] = []
                
                if filterForYou {
                    filters.append("for_you".localized)
                }
                
                if filterFollowing {
                    filters.append("following".localized)
                }
                
                onSave?(
                    keyword.trimmingCharacters(in: .whitespaces),
                    filters
                )
                
                fullDismiss?()
            }
        )
    }
}

// MARK: - Views
extension AddKeywordView {
    
    private var keywordInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            TextField(
                "enter_a_keyword".localized,
                text: $keyword
            )
            .font(.system(size: 14))
            .foregroundStyle(.appText)
            .padding(.horizontal, 18)
            .frame(height: 42)
            .background(AppColor.sectionSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("keyword_hint".localized)
            }
            .font(.system(size: 12))
            .foregroundStyle(AppColor.secondaryTextColor)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.cardBackground.opacity(0.5))
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    private var filterSectionView: some View {
        VStack(spacing: 12) {
            filterHeaderView
            filterOptionsView
        }
    }
    
    private var filterHeaderView: some View {
        HStack {
            
            Text("filter_from".localized)
                .font(.system(size: 16))
                .foregroundStyle(.appText)
            
            Spacer()
            
            Button {
                let value = !allSelected
                filterForYou = value
                filterFollowing = value
            } label: {
                Text("select_all".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColor.accentRed)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var filterOptionsView: some View {
        VStack(spacing: 0) {
            
            checkboxRow(
                title: "for_you".localized,
                isChecked: $filterForYou
            )
            
            Divider()
                .padding(.leading, 24)
            
            checkboxRow(
                title: "following".localized,
                isChecked: $filterFollowing
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.cardBackground.opacity(0.5))
        )
        .padding(.horizontal, 24)
    }
    
    private func checkboxRow(title: String, isChecked: Binding<Bool>) -> some View {
        
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.appText)
            
            Spacer()
            
            Image(
                systemName: isChecked.wrappedValue
                ? "checkmark.square.fill"
                : "square"
            )
            .foregroundStyle(
                isChecked.wrappedValue
                ? AppColor.accentRed
                : AppColor.secondaryTextColor
            )
            .font(.system(size: 18))
            .onTapGesture {
                isChecked.wrappedValue.toggle()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    NavigationStack {
        AddKeywordView()
    }
}
