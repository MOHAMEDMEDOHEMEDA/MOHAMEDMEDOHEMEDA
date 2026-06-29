//
//  PaymentIntentResponse.swift
//  Binbon
//
//  Created by Salah Khaled on 20/04/2026.
//

import Foundation

struct PaymentIntentResponse: Decodable, Equatable {
    let paymentRequired: Bool?
    let paymentIntentId: String?
    let clientSecret: String?
    let publishableKey: String?
    let amount: Double?
    let currency: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentRequired = "payment_required"
        case paymentIntentId = "payment_intent_id"
        case clientSecret = "client_secret"
        case publishableKey = "publishable_key"
        case amount
        case currency
    }
}
