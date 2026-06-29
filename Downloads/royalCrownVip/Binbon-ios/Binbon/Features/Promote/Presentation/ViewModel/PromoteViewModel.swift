//
//  PromoteViewModel.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import UIKit
import Combine

@MainActor
final class PromoteViewModel: ObservableObject {

    // MARK: - Properties
    @Published var selectedObjective: PromoteObjective = .boostAccount
    @Published var selectedGoal: PromoteGoal = .moreVideoViews
    @Published var post: PromotePost?
    @Published var packs: [PromotionPack] = []
    @Published var selectedPackID: Int?

    // Customize panel
    @Published var isCustomizeExpanded: Bool = false
    @Published var appearance: PromotionAppearance = .automatic
    @Published var budgetPerDay: Double = 154
    @Published var durationDays: Double = 13

    // Custom audience targeting (Custom appearance)
    @Published var showCustomAudience: Bool = false
    @Published var customAudience = CustomAudience()

    @Published var agreedToProgram: Bool = false
    @Published var agreedToServiceTerms: Bool = false

    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var isPaying: Bool = false
    @Published var showWarningToast: Bool = false
    @Published var showAppStoreSheet: Bool = false

    /// Mock email shown on the App Store sheet — wire to the signed-in user
    /// once auth surfaces the real value.
    let purchaseAccountEmail = "hamzahasan@gmail.com"

    let currencyCode = "USD"
    private let settingRepo: SettingRepoProtocol

    // Slider bounds for the customize panel.
    let budgetRange: ClosedRange<Double> = 5...1000
    let durationRange: ClosedRange<Double> = 1...90

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(settingRepo: container.makeSettingRepo())
    }

    // MARK: - Derived state
    var selectedPack: PromotionPack? {
        packs.first { $0.id == selectedPackID }
    }

    var totalPrice: Double {
        switch appearance {
        case .automatic:
            return selectedPack?.price ?? 0
        case .custom:
            // Custom campaigns are billed per-day across the chosen duration.
            return budgetPerDay * durationDays
        }
    }

    /// Estimated reach for the configured campaign, formatted with grouping
    /// separators, e.g. "29,891 - 1,161,668".
    var estimatedViewsRange: String {
        // TODO: Replace with reach estimate returned by the API.
        let low = Int((budgetPerDay * durationDays * 14).rounded())
        let high = Int((budgetPerDay * durationDays * 560).rounded())
        return "\(grouped(low)) - \(grouped(high))"
    }

    var budgetPerDayText: String {
        String(format: "%.2f %@ ", budgetPerDay, currencyCode) + "per_day".localized
    }

    var durationText: String {
        let days = Int(durationDays)
        return "\(days) " + "days".localized
    }

    private func grouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    var totalPriceText: String {
        String(format: "%.2f %@", totalPrice, currencyCode)
    }

    /// Pay is only enabled once a pack is chosen and both agreements ticked.
    var canPay: Bool {
        selectedPack != nil && agreedToProgram && agreedToServiceTerms
    }

    // MARK: - Lifecycle
    func onAppear() {
        guard packs.isEmpty else { return }
        fetch()
    }

    func fetch() {
        post = PromotePost(
            id: 1,
            imageURL: "artist_7",
            caption: "#CapCut حل-مالك الصيني-شعب 3...",
            postedDate: "03/26/2025"
        )

        packs = [
            PromotionPack(id: 1, imageURL: "play-2", reachRange: "1.4K - 3.6K",  durationText: "video_views_in_1_day".localized, price: 3.00,  isRecommended: false),
            PromotionPack(id: 2, imageURL: "play-1", reachRange: "3.8K - 9.6K",  durationText: "video_views_in_1_day".localized, price: 8.00,  isRecommended: true),
            PromotionPack(id: 3, imageURL: "play-3", reachRange: "11.4K - 28.5K", durationText: "video_views_in_1_day".localized, price: 23.76, isRecommended: false),
        ]

        selectedPackID = packs.first(where: { $0.isRecommended })?.id ?? packs.first?.id
    }

    // MARK: - Actions
    func selectObjective(_ objective: PromoteObjective) {
        selectedObjective = objective
    }

    func selectGoal(_ goal: PromoteGoal) {
        selectedGoal = goal
    }

    func selectPack(_ pack: PromotionPack) {
        selectedPackID = pack.id
    }

    func selectAppearance(_ appearance: PromotionAppearance) {
        self.appearance = appearance
        // Picking "Custom" opens the audience-targeting screen.
        if appearance == .custom {
            showCustomAudience = true
        }
    }

    /// Toggles the inline customize panel (estimate, appearance, budget…).
    func toggleCustomize() {
        isCustomizeExpanded.toggle()
    }

    func customize() {
        // TODO: Navigate to the customize-pack flow.
    }

    func pay() {
        guard !isPaying, !showAppStoreSheet else { return }
        guard canPay else {
            showWarningToast = true
            return
        }
        isPaying = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isPaying = false
            showAppStoreSheet = true
        }
    }

    func confirmAppStorePurchase() {
        showAppStoreSheet = false
    }

    func dismissAppStoreSheet() {
        showAppStoreSheet = false
    }
}
