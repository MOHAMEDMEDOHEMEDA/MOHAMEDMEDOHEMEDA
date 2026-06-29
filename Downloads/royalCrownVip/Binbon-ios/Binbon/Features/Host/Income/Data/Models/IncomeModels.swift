//
//  IncomeModels.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// One earnings category in the income breakdown. `color` is a fixed data-viz
/// color (a chart-series color, not a theme token) so categories stay
/// distinguishable in every theme — same rationale as chart legends.
struct IncomeCategory: Identifiable {
    let id = UUID()
    let titleKey: String
    let amount: Int
    let color: Color
}
