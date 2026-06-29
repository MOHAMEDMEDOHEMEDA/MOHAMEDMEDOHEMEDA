//
//  LegalSettingsView.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import SwiftUI

struct LegalSettingsView: View {
    @StateObject var viewModel = LegalSettingsViewModel()

    var body: some View {
        ZStack {
            ExpandView {
                Section("terms_and_conditions".localized) { termsAndConditionsSection }
                Section("privacy_policy".localized) { privacyPolicySection }
                Section("fair_use_policy".localized) { fairUsePolicySection }
                Section("intellectual_property_rights".localized) { ipRightsSection }
                Section("data_deletion_request".localized) { dataDeletionRequestSection }
            }
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "legal_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchLegalSettings() }
    }

    // MARK: - Sections
    private func sectionContent(_ sections: [LegalSection]?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sections ?? []) { section in
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title ?? "")
                        .font(.system(size: 14, weight: .bold))

                    Text(section.content ?? "")
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
        }
    }

    private var termsAndConditionsSection: some View {
        sectionContent(viewModel.termsAndConditions?.sections)
    }

    private var privacyPolicySection: some View {
        sectionContent(viewModel.privacyPolicy?.sections)
    }

    private var fairUsePolicySection: some View {
        sectionContent(viewModel.fairUsePolicy?.sections)
    }


    private var ipRightsSection: some View {
        sectionContent(viewModel.intellectualPropertyRights?.sections)
    }

    private var dataDeletionRequestSection: some View {
        sectionContent(viewModel.dataDeletionRequest?.sections)
    }

    private func contentSection(_ content: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let content = content {
                FAQCell(
                    title: nil,
                    description: content,
                    isLast: true
                )
            } else {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "doc.text")
                .font(.system(size: 32))
                .foregroundStyle(.appText.opacity(0.7))

            Text("no_content_available".localized)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}


#Preview("Legal Settings View") {
    LegalSettingsView()
}
