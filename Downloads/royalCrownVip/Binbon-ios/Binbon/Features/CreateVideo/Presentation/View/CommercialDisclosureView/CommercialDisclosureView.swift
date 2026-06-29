//
//  CommercialDisclosureView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CommercialDisclosureView: View {

    @Binding var isDisclosed: Bool
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    @State private var selfBrand = false
    @State private var sponsored = false
    @State private var dialog: CommercialDisclosureDialog?
    @State private var showToast = false
    @State private var showHelp = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CommercialDisclosureHeader(onClose: onClose,
                                           onHelp: { showHelp = true })
                CommercialDisclosureCard(isDisclosed: $isDisclosed,
                                         selfBrand: $selfBrand,
                                         sponsored: $sponsored)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                Spacer(minLength: 0)
                CommercialDisclosureSaveButton(onSave: handleSave)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .adaptiveContentWidth()
            .appBackground()

            if showToast {
                VStack {
                    CommercialDisclosureSuccessToast(message: "cd_ads_enabled_toast".localized)
                    Spacer()
                }
                .padding(.top, 8)
                .transition(.opacity)
            }

            if let dialog {
                dialogView(dialog)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onChange(of: isDisclosed) {
            if isDisclosed {
                dialog = .enabledInfo
            } else {
                selfBrand = false
                sponsored = false
                dialog = nil
            }
        }
        .fullScreenCover(isPresented: $showHelp) {
            CommercialDisclosureHelpView(onClose: { showHelp = false })
                .localizedLayout()
        }
    }

    // MARK: - Actions
    private func handleSave() {
        if isDisclosed {
            withAnimation { dialog = .saveInfo }
        } else {
            onClose()
        }
    }

    private func enableAds() {
        dialog = nil
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { showToast = false }
        }
    }

    // MARK: - Dialogs
    @ViewBuilder
    private func dialogView(_ dialog: CommercialDisclosureDialog) -> some View {
        switch dialog {
        case .enabledInfo:
            CommercialDisclosureConfirmDialog(
                title: "cd_enabled_title".localized,
                message: "cd_enabled_message".localized,
                leftTitle: "cd_back".localized,
                rightTitle: "cd_continue".localized,
                onLeft: { isDisclosed = false },
                onRight: { self.dialog = .enableAds })

        case .enableAds:
            CommercialDisclosureConfirmDialog(
                image: Image("ad-settings"),
                title: "cd_enable_ads_title".localized,
                message: "cd_enable_ads_message".localized,
                leftTitle: "cd_cancel".localized,
                rightTitle: "cd_enable".localized,
                onLeft: { self.dialog = nil },
                onRight: enableAds)

        case .saveInfo:
            CommercialDisclosureConfirmDialog(
                title: "cd_save_title".localized,
                message: "cd_save_message".localized,
                leftTitle: "cd_back".localized,
                rightTitle: "cd_continue".localized,
                onLeft: { self.dialog = nil },
                onRight: { self.dialog = nil; onClose() })
        }
    }
}

enum CommercialDisclosureDialog: Identifiable {
    case enabledInfo
    case enableAds
    case saveInfo

    var id: Int {
        switch self {
        case .enabledInfo: return 0
        case .enableAds:   return 1
        case .saveInfo:    return 2
        }
    }
}
