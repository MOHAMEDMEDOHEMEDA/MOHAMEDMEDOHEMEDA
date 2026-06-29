//
//  ReportIPInfringementView.swift
//  Binbon
//
//  Created by Aya Mashaly on 09/06/2026.
//

import SwiftUI

struct ReportIPInfringementView: View {
    
    @Environment(\.router) private var router
    @State private var complaintType  = "ip_copyright".localized
    @State private var workType       = "ip_work_video".localized
    @State private var workDescription = ""
    @State private var contentURL      = ""
    @State private var ownerName        = ""
    @State private var ownerIdentity    = "ip_owner_influencer".localized
    @State private var originalWorkURL  = ""
    @State private var relationship     = "ip_relationship_owner".localized
    @State private var contactName    = ""
    @State private var contactEmail   = ""
    @State private var contactPhone   = ""
    @State private var contactAddress = ""
    @State private var affirm1 = false
    @State private var affirm2 = false
    @State private var affirm3 = false
    @State private var signature = ""
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    titleCard
                    complaintDetailsSection
                    ownershipSection
                    contactSection
                    legalAffirmationsSection
                    SubmitSection
                    footer
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContentWidth()
            }
        }
        .appBackground()
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Image("binbon-logo")
                .resizable()
                .frame(width: 70, height: 50)
            Spacer()
            
            Text("ip_for_business".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppColor.textPrimary)
            
            Spacer()
            
            Button { } label: {
                Image("profile-menu")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.top, 10)
    }
    
    private var titleCard: some View {
        IPSectionCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("ip_report_title".localized)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("ip_report_intro".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, 15)
                
                Text("ip_copyright_trademark".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.bottom, 25)
            }
        }
    }
    
    private var complaintDetailsSection: some View {
        IPSectionCard(title: "ip_complaint_details".localized) {
            VStack(alignment: .leading, spacing: 30) {
                field("ip_complaint_type".localized) {
                    IPRadioGroup(
                        options: ["ip_copyright".localized, "ip_trademark".localized],
                        selection: $complaintType
                    )
                }
                
                field("ip_copyrighted_work_type".localized) {
                    IPRadioGroup(
                        options: [
                            "ip_work_video".localized,
                            "ip_work_original_music".localized,
                            "ip_work_non_music_audio".localized,
                            "ip_work_photo".localized,
                            "ip_work_logo".localized,
                            "ip_work_other".localized
                        ],
                        selection: $workType
                    )
                }
                
                field("ip_describe_work".localized) {
                    IPTextEditor(placeholder: "ip_describe_work_placeholder".localized,
                                 text: $workDescription)
                }
                
                field("ip_content_location".localized) {
                    IPTextField(placeholder: "ip_url_placeholder".localized,
                                text: $contentURL)
                }
            }
        }
    }
    
    private var ownershipSection: some View {
        IPSectionCard(title: "ip_ownership_info".localized) {
            VStack(alignment: .leading, spacing: 30) {
                field("ip_owner_name".localized) {
                    IPTextField(placeholder: "ip_owner_name_placeholder".localized, text: $ownerName)
                }
                
                field("ip_owner_identity".localized) {
                    IPRadioGroup(options: [
                        "ip_owner_influencer".localized,
                        "ip_owner_advertiser".localized,
                        "ip_owner_binbon_user".localized,
                        "ip_owner_none".localized
                    ], selection: $ownerIdentity)
                }
                
                field("ip_original_work_location".localized) {
                    IPTextField(placeholder: "ip_url_placeholder".localized, text: $originalWorkURL)
                }
                
                field("ip_relationship".localized) {
                    IPSegmented(options: [
                        "ip_relationship_owner".localized,
                        "ip_relationship_representative".localized
                    ], selection: $relationship)
                }
                
                field("ip_proof_rights".localized) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ip_proof_rights_desc".localized)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColor.textSecondary)
                        IPUploadButton(title: "ip_upload".localized, hint: "ip_upload_hint".localized)
                            .padding(.top, 10)
                    }
                }
                
                field("ip_additional_materials".localized) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ip_additional_materials_desc".localized)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColor.textSecondary)
                        IPUploadButton(title: "ip_upload".localized, hint: "ip_upload_hint".localized)
                            .padding(.top, 10)
                    }
                }
            }
        }
    }
    
    private var contactSection: some View {
        IPSectionCard(title: "ip_contact_info".localized) {
            VStack(alignment: .leading, spacing: 20) {
                field("ip_contact_name".localized) {
                    IPTextField(placeholder: "ip_contact_name_placeholder".localized, text: $contactName, verticalPadding: 8)
                }
                field("ip_contact_email".localized) {
                    IPTextField(placeholder: "ip_contact_email_placeholder".localized, text: $contactEmail, verticalPadding: 8)
                }
                field("ip_contact_phone".localized) {
                    IPTextField(placeholder: "ip_contact_phone_placeholder".localized, text: $contactPhone, verticalPadding: 8)
                }
                field("ip_contact_address".localized) {
                    IPTextField(placeholder: "ip_contact_address_placeholder".localized, text: $contactAddress, verticalPadding: 8)
                }
            }
        }
    }
    
    private var legalAffirmationsSection: some View {
        IPSectionCard(title: "ip_legal_title".localized) {
            VStack(alignment: .leading, spacing: 22) {
                Text("ip_legal_intro".localized)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.textSecondary)
                
                IPCheckbox(text: "ip_legal_affirm1".localized, isOn: $affirm1)
                IPCheckbox(text: "ip_legal_affirm2".localized, isOn: $affirm2)
                IPCheckbox(text: "ip_legal_affirm3".localized, isOn: $affirm3)
                
                Text("ip_legal_signature_label".localized)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.textSecondary)
                
                IPTextField(placeholder: "ip_legal_signature_placeholder".localized,
                            text: $signature, verticalPadding: 12)
            }
        }
    }
    
    private var SubmitSection: some View {
        IPSectionCard {
            Button { } label: {
                Text("submit".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColor.buttonGradient))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var footer: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("binbon-logo")
                .resizable()
                .frame(width: 70, height: 50)
                .padding(.bottom, 16)
            
            IPFooterSection(title: "footer_company".localized, links: [
                "footer_company_about".localized, "footer_company_bytedance".localized,
                "footer_company_binbon".localized, "footer_company_affiliates".localized,
                "footer_company_careers".localized, "footer_company_good".localized
            ])
            IPFooterSection(title: "footer_products".localized, links: [
                "footer_products_creative".localized, "footer_products_brand".localized,
                "footer_products_optimization".localized, "footer_products_ecommerce".localized
            ])
            IPFooterSection(title: "footer_resources".localized, links: [
                "footer_res_center".localized, "footer_res_insights".localized,
                "footer_res_academy".localized, "footer_res_blog".localized,
                "footer_res_marketplace".localized, "footer_res_partners".localized,
                "footer_res_exchange".localized
            ])
            IPFooterSection(title: "footer_support".localized, links: [
                "footer_support_help".localized, "footer_support_contact".localized
            ])
            
            footerHeader("footer_for_business".localized, bold: true)
            footerHeader("footer_product_links".localized, bold: false)
            
            Button { } label: {
                Text("footer_language".localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(AppColor.buttonGradient))
            }
            .buttonStyle(.plain)
            .padding(.vertical, 24)
            
            Text("footer_copyright".localized)
                .font(.system(size: 12))
                .foregroundStyle(AppColor.textPrimary)
        }
    }
    
    private func footerHeader(_ title: String, bold: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: bold ? .bold : .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.vertical, 16)
            Divider().overlay(AppColor.hairline)
        }
    }
    
    private func field<Content: View>(_ label: String,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
            content()
        }
    }
}
