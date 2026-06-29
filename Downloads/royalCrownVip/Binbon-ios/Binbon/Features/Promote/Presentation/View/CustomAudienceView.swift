//
//  CustomAudienceView.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct CustomAudienceView: View {
    @StateObject var viewModel: CustomAudienceViewModel
    @Environment(\.dismiss) private var dismiss

    var onSave: ((CustomAudience) -> Void)?

    init(audience: CustomAudience = CustomAudience(),
         onSave: ((CustomAudience) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CustomAudienceViewModel(audience: audience))
        self.onSave = onSave
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                infoBanner

                VStack(alignment: .leading, spacing: 23) {
                    genderSection
                    ageSection
                    interestsSection
                    saveBar
                }
                .padding(.horizontal, 18)
                .padding(.top, 21)
                .padding(.bottom, 28)
                .promoteCard()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .adaptiveContentWidth()
        }
        .scrollIndicators(.hidden)
        .appBackground()
        .appNavigation(title: "custom_audience".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
    }

    // MARK: - Notice banner
    private var infoBanner: some View {
        Text("custom_audience_notice".localized)
            .font(.system(size: 12))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColor.promoteEstimateBannerFill)
            )
    }

    // MARK: - Gender
    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("gender".localized)

            FlowLayout {
                ForEach(AudienceGender.allCases) { gender in
                    AudienceChip(
                        title: gender.title,
                        isSelected: viewModel.gender == gender
                    ) {
                        viewModel.selectGender(gender)
                    }
                }
            }
        }
    }

    // MARK: - Age
    private var ageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("age".localized)

            FlowLayout {
                AudienceChip(title: "all".localized, isSelected: viewModel.isAllAges) {
                    viewModel.selectAllAges()
                }
                ForEach(viewModel.ageOptions, id: \.self) { age in
                    AudienceChip(
                        title: age,
                        isSelected: viewModel.selectedAges.contains(age)
                    ) {
                        viewModel.toggleAge(age)
                    }
                }
            }
        }
    }

    // MARK: - Interests
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("interests".localized)

            FlowLayout {
                AudienceChip(title: "all".localized, isSelected: viewModel.isAllInterests) {
                    viewModel.selectAllInterests()
                }
                ForEach(viewModel.interestOptions, id: \.self) { interest in
                    AudienceChip(
                        title: interest.localized,
                        isSelected: viewModel.selectedInterests.contains(interest)
                    ) {
                        viewModel.toggleInterest(interest)
                    }
                }
            }
        }
    }

    // MARK: - Save bar
    private var saveBar: some View {
        Button {
            viewModel.save()
            onSave?(viewModel.audience)
            dismiss()
        } label: {
            Text("save".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppColor.primaryTextColor)
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.customizeButtonFill)
                )
        }
        .buttonStyle(.plain)
        .padding(.vertical, 16)
    }

    // MARK: - Helpers
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(AppColor.primaryTextColor)
    }
}

#Preview {
    NavigationStack {
        CustomAudienceView()
    }
}
