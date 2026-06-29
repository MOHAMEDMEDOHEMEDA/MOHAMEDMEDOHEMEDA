//
//  RegistrationData.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import Foundation

// MARK: - RegistrationData
struct RegistrationData {
    var email: String = ""
    var phoneNumber: String = ""
    var dialCode: String = "+20"
    var countryKey: String = "eg"
    var password: String = ""
    var confirmPassword: String = ""
    var hasAgreedToTerms: Bool = false
    var username: String = ""
    var fullName: String = ""
    var dateOfBirth: String = ""
    var gender: GenderType = .male
}

enum GenderType: String, CaseIterable, Hashable {
    case male = "male"
    case female = "female"
}


// MARK: - RegisterUserRequest
struct RegisterUserRequest: Encodable {
    let login_method: String        // "email"
    let identity: String            // unique identifier
    let fullname: String
    let username: String
    let user_email: String
    let password: String
    let device: Int                 // 0 = iOS
    let mobile_country_code: Int
    let user_mobile_no: String
    let date_of_birth: String       // "yyyy-MM-dd"
    let auth_mode: String           // "multi_account"
    
    init(from data: RegistrationData) {
        login_method        = "email"
        identity            = data.email
        fullname            = data.fullName
        username            = data.username
        user_email          = data.email
        password            = data.password
        device              = 0
        // Strip the leading "+" from the dial code to get the numeric country code
        mobile_country_code = Int(data.dialCode.replacingOccurrences(of: "+", with: "")) ?? 1
        user_mobile_no      = data.phoneNumber
        date_of_birth       = data.dateOfBirth
        auth_mode           = "multi_account"
    }
}
