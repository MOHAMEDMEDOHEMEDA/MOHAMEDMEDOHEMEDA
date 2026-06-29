//
//  PromoteAppStoreSheet.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct PromoteAppStoreSheet: View {
    let priceText: String
    let accountEmail: String
    var onClose: () -> Void
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            purchaseCard
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 10,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 10
            )
            .fill(AppColor.promoteCardFill)
        )
    }
    
    // MARK: - Header (X + App Store title)
    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 35, height: 35)
                    .background(Circle().fill(AppColor.promoteSheetCloseFill))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("app_store".localized)
                .font(.body.weight(.bold))
            
            Spacer()
            
            Color.clear.frame(width: 35, height: 35)
        }
    }
    
    // MARK: - Purchase card
    private var purchaseCard: some View {
        Button(action: onConfirm) {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    appIcon
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("promote_app_name".localized)
                            .font(.callout.weight(.bold))
                        
                        HStack(spacing: 6) {
                            Text("promote_app_subtitle".localized)
                                .font(.caption.weight(.bold))
                                .lineLimit(1)
                            ageBadge
                        }
                        
                        Text("in_app_purchase".localized)
                            .font(.caption)
                    }
                    
                    Spacer(minLength: 0)
                }
                
                Rectangle()
                    .fill(AppColor.promoteSheetDivider)
                    .frame(height: 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(priceText)
                        .font(.caption.weight(.bold))
                    
                    Text("one_time_fee".localized)
                        .font(.caption)
                    
                    Text("\("account_label".localized) \(accountEmail)")
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.promoteSheetInnerFill)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Pieces
    private var appIcon: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(width: 55, height: 53)
            .overlay(
                Image("binbon-logo")
                    .resizable()
                    .frame(width: 40, height: 40)
            )
    }
    
    private var ageBadge: some View {
        Text("promote_age_rating".localized)
            .font(.system(size: 10))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(AppColor.textPrimary.opacity(0.5), lineWidth: 1)
            )
    }
}
