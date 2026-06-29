//
//  PromoteView.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteView: View {
    @StateObject var viewModel = PromoteViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showPriceDetails = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                goalCard

                if let post = viewModel.post {
                    PromotePostCard(post: post)
                        .promoteCard()
                }

                packCard

                if viewModel.isCustomizeExpanded {
                    customizePackCard
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                agreementCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .adaptiveContentWidth()
        }
        .scrollIndicators(.hidden)
        .appBackground()
        .appNavigation(title: "promote".localized)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .overlay(alignment: .top) {
            if viewModel.showWarningToast {
                PromoteWarningToast(message: "promote_review_terms_first".localized)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .task(id: viewModel.showWarningToast) {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.showWarningToast = false
                        }
                    }
            }
        }
        .overlay {
            if viewModel.showAppStoreSheet {
                appStoreSheet
            }
        }
        .overlay {
            if viewModel.isPaying {
                PromotePayingPopup()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showWarningToast)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isPaying)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showAppStoreSheet)
        .onAppear { viewModel.onAppear() }
        .navigationDestination(isPresented: $viewModel.showCustomAudience) {
            CustomAudienceView(audience: viewModel.customAudience) { audience in
                viewModel.customAudience = audience
            }
        }
    }
    
    // MARK: - Choose your goal
    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("choose_your_goal".localized)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PromoteObjective.allCases) { objective in
                        PromoteObjectiveChip(
                            title: objective.title,
                            isSelected: viewModel.selectedObjective == objective
                        ) {
                            viewModel.selectObjective(objective)
                        }
                    }
                }
            }

            VStack(spacing: 14) {
                ForEach(PromoteGoal.allCases) { goal in
                    PromoteGoalRow(
                        goal: goal,
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        viewModel.selectGoal(goal)
                    }
                }
            }
        }
        .promoteCard()
    }

    // MARK: - Choose a promotion pack
    private var packCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("choose_a_promotion_pack".localized)

            VStack(spacing: 14) {
                ForEach(Array(viewModel.packs.enumerated()), id: \.element.id) { index, pack in
                    PromotionPackCell(
                        pack: pack,
                        currencyCode: viewModel.currencyCode,
                        isSelected: viewModel.selectedPackID == pack.id,
                        accent: AppColor.packTierAccents[index % AppColor.packTierAccents.count]
                    ) {
                        viewModel.selectPack(pack)
                    }
                }
            }

            CustomizePillView(
                action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.toggleCustomize()
                    }
                },
                imageName: "bitcoin-icons_magic-wand-filled"
            )
        }
        .promoteCard()
    }

    // MARK: - Customize promotion pack
    private var customizePackCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("choose_a_promotion_pack".localized)
                .font(.body.weight(.medium))
            
            PromoteEstimateBanner(
                value: viewModel.estimatedViewsRange,
                caption: "estimated_profile_views".localized
            )

            sectionHeader("choose_a_promotion_pack".localized)

            VStack(spacing: 14) {
                ForEach(PromotionAppearance.allCases) { appearance in
                    PromoteRadioRow(
                        title: appearance.title,
                        isSelected: viewModel.appearance == appearance
                    ) {
                        viewModel.selectAppearance(appearance)
                    }
                }
            }

            Divider().overlay(AppColor.textPrimary.opacity(0.15))

            sectionHeader("set_budget_and_duration".localized)

            PromoteSliderRow(
                title: "budget".localized,
                valueText: viewModel.budgetPerDayText,
                value: $viewModel.budgetPerDay,
                range: viewModel.budgetRange
            )

            PromoteBudgetHintPill(text: "budget_likely_to_reach".localized)

            PromoteSliderRow(
                title: "duration".localized,
                valueText: viewModel.durationText,
                value: $viewModel.durationDays,
                range: viewModel.durationRange
            )

            CustomizePillView(
                action: viewModel.customize,
                imageName: "Choose_promotion_pack",
                label: "choose_a_promotion_pack".localized
            )
        }
        .promoteCard()
    }

    // MARK: - Promote agreement
    private var agreementCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("promote".localized)
                .font(.body.weight(.medium))

            PromoteCheckboxRow(
                text: "promote_program_agreement".localized,
                isChecked: viewModel.agreedToProgram
            ) {
                viewModel.agreedToProgram.toggle()
            }

            PromoteCheckboxRow(
                text: "promote_terms_agreement".localized,
                isChecked: viewModel.agreedToServiceTerms
            ) {
                viewModel.agreedToServiceTerms.toggle()
            }

            Text("promote_coins_notice".localized)
                .font(.caption)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .promoteCard()
    }

    // MARK: - App Store sheet
    private var appStoreSheet: some View {
        ZStack(alignment: .bottom) {
            AppColor.promoteSheetScrim
                .ignoresSafeArea()
                .onTapGesture { viewModel.dismissAppStoreSheet() }

            PromoteAppStoreSheet(
                priceText: viewModel.totalPriceText,
                accountEmail: viewModel.purchaseAccountEmail,
                onClose: { viewModel.dismissAppStoreSheet() },
                onConfirm: { viewModel.confirmAppStorePurchase() }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Bottom bar
    private var bottomBar: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.totalPriceText)
                    .font(.caption.weight(.bold))

                Button {
                    withAnimation { showPriceDetails.toggle() }
                } label: {
                    HStack(spacing: 3) {
                        Text("see_price_details".localized)
                            .font(.caption)
                        Image(systemName: "chevron.up")
                            .font(.system(size: 10, weight: .semibold))
                            .rotationEffect(.degrees(showPriceDetails ? 180 : 0))
                    }
                }
                .foregroundStyle(AppColor.primaryTextColor)
                .buttonStyle(.plain)
            }

            Spacer()

            Button(action: viewModel.pay) {
                Text("pay".localized)
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, 37)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColor.buttonGradient)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppColor.promoteBottomBarFill)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(hex: "0C0C0C").opacity(0.45))
                .frame(height: 0.5)
        }
    }

    // MARK: - Helpers
    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundStyle(AppColor.textPrimary.opacity(0.7))
        }
    }
}

// MARK: - Card container
extension View {
    func promoteCard() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColor.promoteCardFill)
            )
    }
}

#Preview {
    NavigationStack {
        PromoteView()
    }
}
