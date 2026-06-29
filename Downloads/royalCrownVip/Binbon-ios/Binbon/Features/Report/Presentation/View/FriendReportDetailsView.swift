//
//  FriendReportDetailsView.swift
//  Binbon

//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 17/06/2026.
//
import SwiftUI

struct FriendReportDetailsView: View {

    let friend: FriendItem
    let reason: FriendReportReason

    @Environment(\.dismiss) private var dismiss
    @State private var additionalNote = ""
    @State private var videoLink = ""
    @State private var evidenceImages: [PickedReportImage] = []
    @State private var isSubmitting = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                reasonHeader
                additionalNoteSection
                videoLinkSection
                evidenceSection
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .adaptiveContentWidth()
        }
        .orangeBottomGradientBackground()
        .appNavigation(title: "report".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Reason

    private var reasonHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(reason.titleKey.localized)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.appText)

            Text(reason.descriptionKey.localized)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.appText.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Fields

    private var additionalNoteSection: some View {
        FriendReportField(label: "friend_report_additional_note".localized) {
            ZStack(alignment: .topLeading) {
                if additionalNote.isEmpty {
                    Text("friend_report_additional_note_placeholder".localized)
                        .font(.system(size: 14))
                        .foregroundStyle(.appText.opacity(0.45))
                        .allowsHitTesting(false)
                }

                TextField("", text: $additionalNote, axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText)
                    .tint(.appText)
                    .lineLimit(4...8)
            }
            .frame(minHeight: 100, alignment: .topLeading)
        }
    }

    private var videoLinkSection: some View {
        FriendReportField(label: "friend_report_video_link".localized) {
            ZStack(alignment: .leading) {
                if videoLink.isEmpty {
                    Text("friend_report_video_link_placeholder".localized)
                        .font(.system(size: 14))
                        .foregroundStyle(.appText.opacity(0.45))
                        .allowsHitTesting(false)
                }

                TextField("", text: $videoLink)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText)
                    .tint(.appText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
            }
        }
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("friend_report_evidence_images".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appText)

            Text("friend_report_evidence_hint".localized)
                .font(.system(size: 13))
                .foregroundStyle(.appText.opacity(0.75))

            FriendReportEvidenceView(images: $evidenceImages)
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 12) {
            AppButton(
                title: "friend_report_submit".localized,
                isLoading: $isSubmitting,
                action: submit
            )

            DefaultPlainButton(title: "cancel".localized) {
                dismiss()
            }
        }
        .padding(.top, 8)
    }

    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true
        // Mock-backed until the report API ships.
        Toaster.shared.show(.success(), "friend_report_submitted".localized, 3)
        dismiss()
        isSubmitting = false
    }
}


// MARK: - Field chrome

private struct FriendReportField<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appText)

            content
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appText.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appText.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        FriendReportDetailsView(
            friend: .samples[0],
            reason: FriendReportReason.reportsReasons[0]
        )
    }
}
