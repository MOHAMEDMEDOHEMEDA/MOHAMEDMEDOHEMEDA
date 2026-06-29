//
//  String.swift
//  Binbon
//
//  Created by Salah Khaled on 09/05/2026.
//

import Foundation

extension String {
    func zodiac() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: self) else { return "Select Date" }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch (month, day) {
        case (1, 1...19):   return "Capricorn ♑"
        case (1, 20...31):  return "Aquarius ♒"
        case (2, 1...18):   return "Aquarius ♒"
        case (2, 19...29):  return "Pisces ♓"
        case (3, 1...20):   return "Pisces ♓"
        case (3, 21...31):  return "Aries ♈"
        case (4, 1...19):   return "Aries ♈"
        case (4, 20...30):  return "Taurus ♉"
        case (5, 1...20):   return "Taurus ♉"
        case (5, 21...31):  return "Gemini ♊"
        case (6, 1...20):   return "Gemini ♊"
        case (6, 21...30):  return "Cancer ♋"
        case (7, 1...22):   return "Cancer ♋"
        case (7, 23...31):  return "Leo ♌"
        case (8, 1...22):   return "Leo ♌"
        case (8, 23...31):  return "Virgo ♍"
        case (9, 1...22):   return "Virgo ♍"
        case (9, 23...30):  return "Libra ♎"
        case (10, 1...22):  return "Libra ♎"
        case (10, 23...31): return "Scorpio ♏"
        case (11, 1...21):  return "Scorpio ♏"
        case (11, 22...30): return "Sagittarius ♐"
        case (12, 1...21):  return "Sagittarius ♐"
        default:            return "Capricorn ♑"
        }
    }
}
