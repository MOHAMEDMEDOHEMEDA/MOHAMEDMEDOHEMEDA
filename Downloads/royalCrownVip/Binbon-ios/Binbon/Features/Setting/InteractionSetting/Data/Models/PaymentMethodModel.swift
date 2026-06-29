//
//  PaymentMethodModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 04/06/2026.
//

import SwiftUI

struct PaymentCard: Identifiable {
    let id = UUID()
    let brandImage: String
    let maskedNumber: String
    let expiry: String
    let ccv: String
    var holderName: String = ""
}

struct PaymentWallet: Identifiable {
    let id = UUID()
    let brandImage: String
    let title: String
}

