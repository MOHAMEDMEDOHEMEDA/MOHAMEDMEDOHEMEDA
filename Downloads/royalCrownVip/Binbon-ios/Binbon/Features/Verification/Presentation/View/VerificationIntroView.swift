//
//  VerificationIntroView.swift
//  Binbon
//
//  The verification upsell shown when the user taps the floating assistive
//  button. Lays out the perks of getting verified and a Standard vs. Verified
//  comparison, then routes into the actual verification flow on "Verify now".
//

import SwiftUI

struct VerificationIntroView: View {

    // MARK: - Properties
    @Environment(\.router) private var router
    @Environment(\.dismiss) private var dismiss

    /// Live downward drag from the grabber; past the threshold the page pops.
    @State private var dragOffset: CGFloat = 0

    private let benefits: [Benefit] = [
        Benefit(icon: "checkmark.shield.fill",
                title: "verify_benefit_badge_title",
                detail: "verify_benefit_badge_desc"),
        Benefit(icon: "gift.fill",
                title: "verify_benefit_gifts_title",
                detail: "verify_benefit_gifts_desc"),
        Benefit(icon: "dollarsign.circle.fill",
                title: "verify_benefit_money_title",
                detail: "verify_benefit_money_desc"),
        Benefit(icon: "chart.line.uptrend.xyaxis",
                title: "verify_benefit_reach_title",
                detail: "verify_benefit_reach_desc")
    ]

    private let comparisons: [String] = [
        "verify_compare_badge",
        "verify_compare_gifts",
        "verify_compare_money",
        "verify_compare_discovery"
    ]

    // MARK: - Body
    var body: some View {
        ZStack {
            // Fixed gradient behind the sliding content (purple top → orange bottom).
            AppColor.verificationGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    grabber
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    header
                        .padding(.bottom, 28)

                    benefitsList
                        .padding(.bottom, 24)

                    comparisonCard
                        .padding(.bottom, 28)

                    actions
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .adaptiveContentWidth()
            }
            .offset(y: max(0, dragOffset))
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Grabber
    private var grabber: some View {
        Capsule()
            .fill(Color.appText.opacity(0.4))
            .frame(width: 44, height: 5)
            .padding(12) // larger touch target for the swipe-down gesture
            .contentShape(Rectangle())
            .gesture(dismissDrag)
    }

    /// Swipe the grabber down to close and pop the page.
    private var dismissDrag: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appWhite)
                    .frame(width: 92, height: 92)
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.appPurple)
            }

            Text("verify_account_intro_title".localized)
                .font(.title.bold())
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("verify_account_intro_subtitle".localized)
                .font(.subheadline)
                .foregroundStyle(.appText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
    }

    // MARK: - Benefits
    private var benefitsList: some View {
        VStack(spacing: 20) {
            ForEach(benefits) { benefit in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.appText.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: benefit.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appText)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(benefit.title.localized)
                            .font(.headline)
                            .foregroundStyle(.appText)
                        Text(benefit.detail.localized)
                            .font(.subheadline)
                            .foregroundStyle(.appText.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - Comparison
    private var comparisonCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("verify_compare_standard".localized)
                    .font(.subheadline)
                    .foregroundStyle(.appText.opacity(0.7))
                    .frame(width: 90)
                Text("verify_compare_verified".localized)
                    .font(.subheadline.bold())
                    .foregroundStyle(.appText)
                    .frame(width: 70)
            }
            .padding(.bottom, 16)

            ForEach(Array(comparisons.enumerated()), id: \.offset) { index, key in
                HStack(spacing: 0) {
                    Text(key.localized)
                        .font(.subheadline)
                        .foregroundStyle(.appText)
                    Spacer(minLength: 0)
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.appText.opacity(0.5))
                        .frame(width: 90)
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.appText)
                        .frame(width: 70)
                }
                .padding(.vertical, 11)

                if index < comparisons.count - 1 {
                    Divider()
                        .overlay(Color.appText.opacity(0.12))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appText.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appText.opacity(0.18), lineWidth: 1)
                )
        )
    }

    // MARK: - Actions
    private var actions: some View {
        VStack(spacing: 16) {
            Button {
                router.navigate(.verification)
            } label: {
                Text("verify_now".localized)
                    .font(.callout.bold())
                    .foregroundStyle(Color.appPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appWhite)
                            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                    )
            }

            Button("maybe_later".localized) {
                dismiss()
            }
            .font(.callout)
            .foregroundStyle(.appText)

            Button("dont_show_again".localized) {
                // No persistent "seen" flag yet — hide the entry point so the
                // upsell stops appearing for now, then close the sheet.
                AssistiveButtonState.shared.hideTemporarily()
                dismiss()
            }
            .font(.callout)
            .foregroundStyle(.appText.opacity(0.6))
        }
    }
}

// MARK: - Benefit Model
private struct Benefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

#Preview {
    NavigationStack {
        VerificationIntroView()
    }
}
