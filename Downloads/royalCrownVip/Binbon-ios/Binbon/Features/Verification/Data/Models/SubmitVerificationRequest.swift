//
//  SubmitVerificationRequest.swift
//  Binbon
//
//  Created by Salah Khaled on 20/04/2026.
//

import UIKit

struct SubmitVerificationRequest {
    
    var paymentIntentId: String?
    var fullName: String?
    var idNumber: String?
    var address: String?
    var dateOfBirth: String?
    var phone: String?
    var country: String?
    var state: String?
    var accountType: String?
    var whatsappUser: String?
    var region: String?
    var village: String?
    
    var idCardFront: UIImage?
    var idCardBack: UIImage?
    var idCardSelfie: UIImage?
}
