//
//  FormValidation.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import Foundation

enum FormValidation {
    
    static func check(_ raw: String, title: String, minLength: Int = 3) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "validation_enter_field".localizedFormat(title.lowercased()) }
        if s.count < minLength { return "validation_enter_full_field".localizedFormat(title.lowercased()) }
        return nil
    }

    static func email(_ raw: String) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "validation_enter_email".localized }
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if s.range(of: pattern, options: .regularExpression) == nil {
            return "validation_invalid_email".localized
        }
        return nil
    }

    static func password(_ raw: String, minLength: Int = 6) -> String? {
        if raw.isEmpty { return "validation_enter_password".localized }
        if raw.count < minLength {
            return "validation_password_min".localizedFormat(minLength)
        }
        return nil
    }

    static func confirmPassword(_ password: String, _ confirm: String) -> String? {
        if confirm.isEmpty { return "validation_confirm_password".localized }
        if password != confirm { return "validation_passwords_no_match".localized }
        return nil
    }

    static func phoneDigits(_ raw: String, minDigits: Int = 7) -> String? {
        let digits = raw.filter(\.isNumber)
        if digits.isEmpty { return "validation_enter_phone".localized }
        if digits.count < minDigits { return "validation_phone_short".localized }
        return nil
    }

    static func terms(_ agreed: Bool) -> String? {
        agreed ? nil : "validation_agree_terms".localized
    }

    static func username(_ raw: String) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "validation_choose_username".localized }
        if s.count < 3 { return "validation_username_min".localized }
        for ch in s where !ch.isLetter && !ch.isNumber && ch != "_" {
            return "validation_username_chars".localized
        }
        return nil
    }

    static func fullName(_ raw: String) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "validation_enter_name".localized }
        if s.count < 2 { return "validation_enter_full_name".localized }
        return nil
    }

    static func idNumber(_ raw: String, minLength: Int = 14) -> String? {
        if raw.isEmpty { return "validation_enter_id".localized }
        if raw.count < minLength {
            return "validation_id_min".localizedFormat(minLength)
        }
        return nil
    }

    static func dateOfBirth(_ dateString: String, minimumAge: Int = 13) -> String? {

        if dateString.isEmpty { return "validation_enter_dob".localized }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return "validation_dob_format".localized
        }

        let calendar = Calendar.current
        guard let age = calendar.dateComponents([.year], from: date, to: Date()).year else { return nil }

        if age < minimumAge {
            return "validation_min_age".localizedFormat(minimumAge)
        }
        return nil
    }

    static func otp(_ code: String, length: Int = 6) -> String? {
        if code.count != length {
            return "validation_enter_code".localizedFormat(length)
        }
        return nil
    }

    static func url(_ raw: String, requireHTTPS: Bool = false) -> String? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "validation_enter_url".localized }

        guard let url = URL(string: s),
              let scheme = url.scheme,
              let host = url.host,
              !host.isEmpty else {
            return "validation_invalid_url".localized
        }
        let allowed = requireHTTPS ? ["https"] : ["http", "https"]
        if !allowed.contains(scheme.lowercased()) {
            return requireHTTPS
            ? "validation_url_https".localized
            : "validation_url_http_https".localized
        }
        return nil
    }
}
