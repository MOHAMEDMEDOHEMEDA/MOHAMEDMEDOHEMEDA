//
//  ReportView.swift
//  Binbon
//
//  Created by Aya Mashaly on 08/06/2026.
//

import SwiftUI

struct ReportView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ReportOptionRow(title: "report_with_details".localized, height: 66) {
                    path.append(ReportReasonsRoute(reasons: ReportReasonItem.topLevel, isSubLevel: false))
                }

                ReportOptionRow(title: "report_without_details".localized, height: 66) {
                    // TODO: Handle quick report without details
                }

                Spacer()
            }
            .appBackground()
            .sheetNavigation(
                title: "report".localized,
                showClose: true,
                hideBackButton: true,
                onClose: { dismiss() }
            )
            .navigationDestination(for: ReportReasonsRoute.self) { route in
                ReportReasonsView(path: $path, reasons: route.reasons, isSubLevel: route.isSubLevel)
            }
            .navigationDestination(for: ReportDetailsData.self) { data in
                ReportDetailsView(
                    reason: data.reason,
                    reasonDescription: data.reasonDescription,
                    bullets: data.bullets
                )
            }
        }
        .environment(\.fullDismiss) { dismiss() }
    }
}

struct ReportReasonsRoute: Hashable {
    let reasons: [ReportReasonItem]
    let isSubLevel: Bool
}
