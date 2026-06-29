//
//  ReportDetailsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI

struct ReportDetailsView: View {
    
    var reason: String = "report_reason_spam"
    var reasonDescription: String? = nil
    var bullets: [String]? = nil
    var onClose: () -> Void = {}
    var onSubmit: () -> Void = {}
    
    @State private var details: String = ""
    @State private var images: [UIImage] = []
    @Environment(\.fullDismiss) private var fullDismiss

    var body: some View {
        container
            .appBackground()
            .sheetNavigation(
                title: "report".localized,
                showClose: true,
                hideBackButton: true,
                onClose: { fullDismiss?() }
            )
    }

    private var container: some View {
        
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ReasonBannerView(reason: reason, reasonDescription: reasonDescription, bullets: bullets)
                content
            }
            
            
            Divider()
                .padding(.top, 16)
            
            submitButton
                .padding(.horizontal, 16)
                .padding(.top, 28)
            
            Spacer()
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("report_details".localized)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(String(format: "report_characters_count".localized, details.count))
                    .font(.system(size: 16, weight: .regular))
            }
            
            ZStack(alignment: .topLeading) {
                if details.isEmpty {
                    Text("report_details_placeholder".localized)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(hex: "9E9E9E"))
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $details, axis: .vertical)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(6, reservesSpace: true)
                    .tint(.black)
            }
            
            ReportAttachmentView(images: $images)
                .padding(.top, 20)
            helperRow
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var helperRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 13))
            Text("report_upload_images_hint".localized)
                .font(.system(size: 13))
        }
        .foregroundStyle(Color(hex: "9E9E9E"))
    }
    
    private var submitButton: some View {
        Button(action: onSubmit) {
            Text("submit".localized)
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColor.buttonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
