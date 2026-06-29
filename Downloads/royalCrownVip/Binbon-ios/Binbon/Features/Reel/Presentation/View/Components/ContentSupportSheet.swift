//
//  ContentSupportSheet.swift
//  Binbon
//

import SwiftUI

struct ContentSupportSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct CoinPackage: Identifiable {
        let id: Int
        let coins: Int
        let price: String
    }

    private static let packages: [CoinPackage] = {
        let raw: [(Int, String)] = [
            (1760, "12.30 USD"), (352, "12.30 USD"), (174, "12.30 USD"),
            (1760, "12.30 USD"), (352, "12.30 USD"), (174, "12.30 USD"),
            (352, "12.30 USD"), (352, "12.30 USD"), (174, "12.30 USD")
        ]
        return raw.enumerated().map { CoinPackage(id: $0.offset, coins: $0.element.0, price: $0.element.1) }
    }()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    @State private var selectedIndex: Int?

    private var selectedPackage: CoinPackage? {
        guard let index = selectedIndex else { return nil }
        return Self.packages.first { $0.id == index }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Self.packages) { package in
                        packageCard(package)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }

            if let package = selectedPackage {
                bottomBar(for: package)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
        .presentationBackground {
            AppColor.shareSheetGradient.ignoresSafeArea()
        }
    }

    private var header: some View {
        ZStack {
            Text("content_support".localized)
                .font(.title3.weight(.bold))
                .foregroundStyle(.appText)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("cancel".localized)

                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func packageCard(_ package: CoinPackage) -> some View {
        let isSelected = selectedIndex == package.id
        return Button {
            selectedIndex = isSelected ? nil : package.id
        } label: {
            VStack(spacing: 8) {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                Text("\(package.coins)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColor.coinTileTitle)

                Text(package.price)
                    .font(.caption)
                    .foregroundStyle(AppColor.coinTilePrice.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AppColor.coinTileSelected : AppColor.coinTileBackground)
            )
        }
        .buttonStyle(.plain)
    }

    private func bottomBar(for package: CoinPackage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("total".localized)
                    .font(.caption)
                    .foregroundStyle(.appText.opacity(0.6))
                Text(package.price)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.appText)
            }

            Spacer()

            Button {
                let coins = package.coins
                dismiss()
                Toaster.shared.show(.success("checkmark.circle.fill"), "coins_sent".localizedFormat(coins))
            } label: {
                Text("send".localized)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColor.buttonGradient, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
