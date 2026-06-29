//  ReportReasonsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI

struct ReportReasonsView: View {

    @Environment(\.router) private var router
    @Environment(\.fullDismiss) private var fullDismiss

    @Binding var path: NavigationPath
    let reasons: [ReportReasonItem]
    var isSubLevel: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ForEach(reasons) { reason in
                ReportOptionRow(title: reason.title.localized, height: 30) {
                    handleSelection(reason.destination)
                }
            }

            Spacer()
        }
        .appBackground()
        .sheetNavigation(
            title: isSubLevel ? "select_report_reason".localized : "report".localized,
            showClose: true,
            onClose: { fullDismiss?() }
        )
    }

    private func handleSelection(_ destination: ReportReasonItem.Destination) {
        switch destination {
        case .details(let data):
            path.append(data)
        case .subReasons(let items):
            path.append(ReportReasonsRoute(reasons: items, isSubLevel: true))
        case .ipInfringement:
            fullDismiss?()
            router.navigate(.reportIPInfringement)
        }
    }
}
