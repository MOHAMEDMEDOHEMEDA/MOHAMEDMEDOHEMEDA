//
//  CountryPicker.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct Country: Identifiable, Hashable {
    
    let id = UUID()
    let key: String
    let nameEn: String
    let nameAr: String
    let dialCode: String
    let flag: String
    
    static let `default` = Country(key: "eg", nameEn: "Egypt", nameAr: "مصر", dialCode: "+20", flag: "🇪🇬")
    
    static let all: [Country] = [
        Country(key: "af", nameEn: "Afghanistan", nameAr: "أفغانستان", dialCode: "+93", flag: "🇦🇫"),
        Country(key: "al", nameEn: "Albania", nameAr: "ألبانيا", dialCode: "+355", flag: "🇦🇱"),
        Country(key: "dz", nameEn: "Algeria", nameAr: "الجزائر", dialCode: "+213", flag: "🇩🇿"),
        Country(key: "ad", nameEn: "Andorra", nameAr: "أندورا", dialCode: "+376", flag: "🇦🇩"),
        Country(key: "ao", nameEn: "Angola", nameAr: "أنغولا", dialCode: "+244", flag: "🇦🇴"),
        Country(key: "ag", nameEn: "Antigua and Barbuda", nameAr: "أنتيغوا وبربودا", dialCode: "+1-268", flag: "🇦🇬"),
        Country(key: "ar", nameEn: "Argentina", nameAr: "الأرجنتين", dialCode: "+54", flag: "🇦🇷"),
        Country(key: "am", nameEn: "Armenia", nameAr: "أرمينيا", dialCode: "+374", flag: "🇦🇲"),
        Country(key: "au", nameEn: "Australia", nameAr: "أستراليا", dialCode: "+61", flag: "🇦🇺"),
        Country(key: "at", nameEn: "Austria", nameAr: "النمسا", dialCode: "+43", flag: "🇦🇹"),
        Country(key: "az", nameEn: "Azerbaijan", nameAr: "أذربيجان", dialCode: "+994", flag: "🇦🇿"),
        Country(key: "bs", nameEn: "Bahamas", nameAr: "جزر البهاما", dialCode: "+1-242", flag: "🇧🇸"),
        Country(key: "bh", nameEn: "Bahrain", nameAr: "البحرين", dialCode: "+973", flag: "🇧🇭"),
        Country(key: "bd", nameEn: "Bangladesh", nameAr: "بنغلاديش", dialCode: "+880", flag: "🇧🇩"),
        Country(key: "bb", nameEn: "Barbados", nameAr: "بربادوس", dialCode: "+1-246", flag: "🇧🇧"),
        Country(key: "by", nameEn: "Belarus", nameAr: "بيلاروسيا", dialCode: "+375", flag: "🇧🇾"),
        Country(key: "be", nameEn: "Belgium", nameAr: "بلجيكا", dialCode: "+32", flag: "🇧🇪"),
        Country(key: "bz", nameEn: "Belize", nameAr: "بليز", dialCode: "+501", flag: "🇧🇿"),
        Country(key: "bj", nameEn: "Benin", nameAr: "بنين", dialCode: "+229", flag: "🇧🇯"),
        Country(key: "bt", nameEn: "Bhutan", nameAr: "بوتان", dialCode: "+975", flag: "🇧🇹"),
        Country(key: "bo", nameEn: "Bolivia", nameAr: "بوليفيا", dialCode: "+591", flag: "🇧🇴"),
        Country(key: "ba", nameEn: "Bosnia and Herzegovina", nameAr: "البوسنة والهرسك", dialCode: "+387", flag: "🇧🇦"),
        Country(key: "bw", nameEn: "Botswana", nameAr: "بوتسوانا", dialCode: "+267", flag: "🇧🇼"),
        Country(key: "br", nameEn: "Brazil", nameAr: "البرازيل", dialCode: "+55", flag: "🇧🇷"),
        Country(key: "bn", nameEn: "Brunei", nameAr: "بروناي", dialCode: "+673", flag: "🇧🇳"),
        Country(key: "bg", nameEn: "Bulgaria", nameAr: "بلغاريا", dialCode: "+359", flag: "🇧🇬"),
        Country(key: "bf", nameEn: "Burkina Faso", nameAr: "بوركينا فاسو", dialCode: "+226", flag: "🇧🇫"),
        Country(key: "bi", nameEn: "Burundi", nameAr: "بوروندي", dialCode: "+257", flag: "🇧🇮"),
        Country(key: "cv", nameEn: "Cabo Verde", nameAr: "الرأس الأخضر", dialCode: "+238", flag: "🇨🇻"),
        Country(key: "kh", nameEn: "Cambodia", nameAr: "كمبوديا", dialCode: "+855", flag: "🇰🇭"),
        Country(key: "cm", nameEn: "Cameroon", nameAr: "الكاميرون", dialCode: "+237", flag: "🇨🇲"),
        Country(key: "ca", nameEn: "Canada", nameAr: "كندا", dialCode: "+1", flag: "🇨🇦"),
        Country(key: "cf", nameEn: "Central African Republic", nameAr: "جمهورية أفريقيا الوسطى", dialCode: "+236", flag: "🇨🇫"),
        Country(key: "td", nameEn: "Chad", nameAr: "تشاد", dialCode: "+235", flag: "🇹🇩"),
        Country(key: "cl", nameEn: "Chile", nameAr: "تشيلي", dialCode: "+56", flag: "🇨🇱"),
        Country(key: "cn", nameEn: "China", nameAr: "الصين", dialCode: "+86", flag: "🇨🇳"),
        Country(key: "co", nameEn: "Colombia", nameAr: "كولومبيا", dialCode: "+57", flag: "🇨🇴"),
        Country(key: "km", nameEn: "Comoros", nameAr: "جزر القمر", dialCode: "+269", flag: "🇰🇲"),
        Country(key: "cg", nameEn: "Congo", nameAr: "الكونغو", dialCode: "+242", flag: "🇨🇬"),
        Country(key: "cd", nameEn: "Congo (DRC)", nameAr: "الكونغو الديمقراطية", dialCode: "+243", flag: "🇨🇩"),
        Country(key: "cr", nameEn: "Costa Rica", nameAr: "كوستاريكا", dialCode: "+506", flag: "🇨🇷"),
        Country(key: "ci", nameEn: "Côte d'Ivoire", nameAr: "ساحل العاج", dialCode: "+225", flag: "🇨🇮"),
        Country(key: "hr", nameEn: "Croatia", nameAr: "كرواتيا", dialCode: "+385", flag: "🇭🇷"),
        Country(key: "cu", nameEn: "Cuba", nameAr: "كوبا", dialCode: "+53", flag: "🇨🇺"),
        Country(key: "cy", nameEn: "Cyprus", nameAr: "قبرص", dialCode: "+357", flag: "🇨🇾"),
        Country(key: "cz", nameEn: "Czech Republic", nameAr: "جمهورية التشيك", dialCode: "+420", flag: "🇨🇿"),
        Country(key: "dk", nameEn: "Denmark", nameAr: "الدنمارك", dialCode: "+45", flag: "🇩🇰"),
        Country(key: "dj", nameEn: "Djibouti", nameAr: "جيبوتي", dialCode: "+253", flag: "🇩🇯"),
        Country(key: "dm", nameEn: "Dominica", nameAr: "دومينيكا", dialCode: "+1-767", flag: "🇩🇲"),
        Country(key: "do", nameEn: "Dominican Republic", nameAr: "جمهورية الدومينيكان", dialCode: "+1-809", flag: "🇩🇴"),
        Country(key: "ec", nameEn: "Ecuador", nameAr: "الإكوادور", dialCode: "+593", flag: "🇪🇨"),
        Country(key: "eg", nameEn: "Egypt", nameAr: "مصر", dialCode: "+20", flag: "🇪🇬"),
        Country(key: "sv", nameEn: "El Salvador", nameAr: "السلفادور", dialCode: "+503", flag: "🇸🇻"),
        Country(key: "gq", nameEn: "Equatorial Guinea", nameAr: "غينيا الاستوائية", dialCode: "+240", flag: "🇬🇶"),
        Country(key: "er", nameEn: "Eritrea", nameAr: "إريتريا", dialCode: "+291", flag: "🇪🇷"),
        Country(key: "ee", nameEn: "Estonia", nameAr: "إستونيا", dialCode: "+372", flag: "🇪🇪"),
        Country(key: "sz", nameEn: "Eswatini", nameAr: "إسواتيني", dialCode: "+268", flag: "🇸🇿"),
        Country(key: "et", nameEn: "Ethiopia", nameAr: "إثيوبيا", dialCode: "+251", flag: "🇪🇹"),
        Country(key: "fj", nameEn: "Fiji", nameAr: "فيجي", dialCode: "+679", flag: "🇫🇯"),
        Country(key: "fi", nameEn: "Finland", nameAr: "فنلندا", dialCode: "+358", flag: "🇫🇮"),
        Country(key: "fr", nameEn: "France", nameAr: "فرنسا", dialCode: "+33", flag: "🇫🇷"),
        Country(key: "ga", nameEn: "Gabon", nameAr: "الغابون", dialCode: "+241", flag: "🇬🇦"),
        Country(key: "gm", nameEn: "Gambia", nameAr: "غامبيا", dialCode: "+220", flag: "🇬🇲"),
        Country(key: "ge", nameEn: "Georgia", nameAr: "جورجيا", dialCode: "+995", flag: "🇬🇪"),
        Country(key: "de", nameEn: "Germany", nameAr: "ألمانيا", dialCode: "+49", flag: "🇩🇪"),
        Country(key: "gh", nameEn: "Ghana", nameAr: "غانا", dialCode: "+233", flag: "🇬🇭"),
        Country(key: "gr", nameEn: "Greece", nameAr: "اليونان", dialCode: "+30", flag: "🇬🇷"),
        Country(key: "gd", nameEn: "Grenada", nameAr: "غرينادا", dialCode: "+1-473", flag: "🇬🇩"),
        Country(key: "gt", nameEn: "Guatemala", nameAr: "غواتيمالا", dialCode: "+502", flag: "🇬🇹"),
        Country(key: "gn", nameEn: "Guinea", nameAr: "غينيا", dialCode: "+224", flag: "🇬🇳"),
        Country(key: "gw", nameEn: "Guinea-Bissau", nameAr: "غينيا بيساو", dialCode: "+245", flag: "🇬🇼"),
        Country(key: "gy", nameEn: "Guyana", nameAr: "غيانا", dialCode: "+592", flag: "🇬🇾"),
        Country(key: "ht", nameEn: "Haiti", nameAr: "هايتي", dialCode: "+509", flag: "🇭🇹"),
        Country(key: "hn", nameEn: "Honduras", nameAr: "هندوراس", dialCode: "+504", flag: "🇭🇳"),
        Country(key: "hu", nameEn: "Hungary", nameAr: "المجر", dialCode: "+36", flag: "🇭🇺"),
        Country(key: "is", nameEn: "Iceland", nameAr: "آيسلندا", dialCode: "+354", flag: "🇮🇸"),
        Country(key: "in", nameEn: "India", nameAr: "الهند", dialCode: "+91", flag: "🇮🇳"),
        Country(key: "id", nameEn: "Indonesia", nameAr: "إندونيسيا", dialCode: "+62", flag: "🇮🇩"),
        Country(key: "ir", nameEn: "Iran", nameAr: "إيران", dialCode: "+98", flag: "🇮🇷"),
        Country(key: "iq", nameEn: "Iraq", nameAr: "العراق", dialCode: "+964", flag: "🇮🇶"),
        Country(key: "ie", nameEn: "Ireland", nameAr: "أيرلندا", dialCode: "+353", flag: "🇮🇪"),
        Country(key: "it", nameEn: "Italy", nameAr: "إيطاليا", dialCode: "+39", flag: "🇮🇹"),
        Country(key: "jm", nameEn: "Jamaica", nameAr: "جامايكا", dialCode: "+1-876", flag: "🇯🇲"),
        Country(key: "jp", nameEn: "Japan", nameAr: "اليابان", dialCode: "+81", flag: "🇯🇵"),
        Country(key: "jo", nameEn: "Jordan", nameAr: "الأردن", dialCode: "+962", flag: "🇯🇴"),
        Country(key: "kz", nameEn: "Kazakhstan", nameAr: "كازاخستان", dialCode: "+7", flag: "🇰🇿"),
        Country(key: "ke", nameEn: "Kenya", nameAr: "كينيا", dialCode: "+254", flag: "🇰🇪"),
        Country(key: "ki", nameEn: "Kiribati", nameAr: "كيريباتي", dialCode: "+686", flag: "🇰🇮"),
        Country(key: "kw", nameEn: "Kuwait", nameAr: "الكويت", dialCode: "+965", flag: "🇰🇼"),
        Country(key: "kg", nameEn: "Kyrgyzstan", nameAr: "قيرغيزستان", dialCode: "+996", flag: "🇰🇬"),
        Country(key: "la", nameEn: "Laos", nameAr: "لاوس", dialCode: "+856", flag: "🇱🇦"),
        Country(key: "lv", nameEn: "Latvia", nameAr: "لاتفيا", dialCode: "+371", flag: "🇱🇻"),
        Country(key: "lb", nameEn: "Lebanon", nameAr: "لبنان", dialCode: "+961", flag: "🇱🇧"),
        Country(key: "ls", nameEn: "Lesotho", nameAr: "ليسوتو", dialCode: "+266", flag: "🇱🇸"),
        Country(key: "lr", nameEn: "Liberia", nameAr: "ليبيريا", dialCode: "+231", flag: "🇱🇷"),
        Country(key: "ly", nameEn: "Libya", nameAr: "ليبيا", dialCode: "+218", flag: "🇱🇾"),
        Country(key: "li", nameEn: "Liechtenstein", nameAr: "ليختنشتاين", dialCode: "+423", flag: "🇱🇮"),
        Country(key: "lt", nameEn: "Lithuania", nameAr: "ليتوانيا", dialCode: "+370", flag: "🇱🇹"),
        Country(key: "lu", nameEn: "Luxembourg", nameAr: "لوكسمبورغ", dialCode: "+352", flag: "🇱🇺"),
        Country(key: "mg", nameEn: "Madagascar", nameAr: "مدغشقر", dialCode: "+261", flag: "🇲🇬"),
        Country(key: "mw", nameEn: "Malawi", nameAr: "مالاوي", dialCode: "+265", flag: "🇲🇼"),
        Country(key: "my", nameEn: "Malaysia", nameAr: "ماليزيا", dialCode: "+60", flag: "🇲🇾"),
        Country(key: "mv", nameEn: "Maldives", nameAr: "جزر المالديف", dialCode: "+960", flag: "🇲🇻"),
        Country(key: "ml", nameEn: "Mali", nameAr: "مالي", dialCode: "+223", flag: "🇲🇱"),
        Country(key: "mt", nameEn: "Malta", nameAr: "مالطا", dialCode: "+356", flag: "🇲🇹"),
        Country(key: "mh", nameEn: "Marshall Islands", nameAr: "جزر مارشال", dialCode: "+692", flag: "🇲🇭"),
        Country(key: "mr", nameEn: "Mauritania", nameAr: "موريتانيا", dialCode: "+222", flag: "🇲🇷"),
        Country(key: "mu", nameEn: "Mauritius", nameAr: "موريشيوس", dialCode: "+230", flag: "🇲🇺"),
        Country(key: "mx", nameEn: "Mexico", nameAr: "المكسيك", dialCode: "+52", flag: "🇲🇽"),
        Country(key: "fm", nameEn: "Micronesia", nameAr: "ميكرونيزيا", dialCode: "+691", flag: "🇫🇲"),
        Country(key: "md", nameEn: "Moldova", nameAr: "مولدوفا", dialCode: "+373", flag: "🇲🇩"),
        Country(key: "mc", nameEn: "Monaco", nameAr: "موناكو", dialCode: "+377", flag: "🇲🇨"),
        Country(key: "mn", nameEn: "Mongolia", nameAr: "منغوليا", dialCode: "+976", flag: "🇲🇳"),
        Country(key: "me", nameEn: "Montenegro", nameAr: "الجبل الأسود", dialCode: "+382", flag: "🇲🇪"),
        Country(key: "ma", nameEn: "Morocco", nameAr: "المغرب", dialCode: "+212", flag: "🇲🇦"),
        Country(key: "mz", nameEn: "Mozambique", nameAr: "موزمبيق", dialCode: "+258", flag: "🇲🇿"),
        Country(key: "mm", nameEn: "Myanmar", nameAr: "ميانمار", dialCode: "+95", flag: "🇲🇲"),
        Country(key: "na", nameEn: "Namibia", nameAr: "ناميبيا", dialCode: "+264", flag: "🇳🇦"),
        Country(key: "nr", nameEn: "Nauru", nameAr: "ناورو", dialCode: "+674", flag: "🇳🇷"),
        Country(key: "np", nameEn: "Nepal", nameAr: "نيبال", dialCode: "+977", flag: "🇳🇵"),
        Country(key: "nl", nameEn: "Netherlands", nameAr: "هولندا", dialCode: "+31", flag: "🇳🇱"),
        Country(key: "nz", nameEn: "New Zealand", nameAr: "نيوزيلندا", dialCode: "+64", flag: "🇳🇿"),
        Country(key: "ni", nameEn: "Nicaragua", nameAr: "نيكاراغوا", dialCode: "+505", flag: "🇳🇮"),
        Country(key: "ne", nameEn: "Niger", nameAr: "النيجر", dialCode: "+227", flag: "🇳🇪"),
        Country(key: "ng", nameEn: "Nigeria", nameAr: "نيجيريا", dialCode: "+234", flag: "🇳🇬"),
        Country(key: "kp", nameEn: "North Korea", nameAr: "كوريا الشمالية", dialCode: "+850", flag: "🇰🇵"),
        Country(key: "mk", nameEn: "North Macedonia", nameAr: "مقدونيا الشمالية", dialCode: "+389", flag: "🇲🇰"),
        Country(key: "no", nameEn: "Norway", nameAr: "النرويج", dialCode: "+47", flag: "🇳🇴"),
        Country(key: "om", nameEn: "Oman", nameAr: "عُمان", dialCode: "+968", flag: "🇴🇲"),
        Country(key: "pk", nameEn: "Pakistan", nameAr: "باكستان", dialCode: "+92", flag: "🇵🇰"),
        Country(key: "pw", nameEn: "Palau", nameAr: "بالاو", dialCode: "+680", flag: "🇵🇼"),
        Country(key: "ps", nameEn: "Palestine", nameAr: "فلسطين", dialCode: "+970", flag: "🇵🇸"),
        Country(key: "pa", nameEn: "Panama", nameAr: "بنما", dialCode: "+507", flag: "🇵🇦"),
        Country(key: "pg", nameEn: "Papua New Guinea", nameAr: "بابوا غينيا الجديدة", dialCode: "+675", flag: "🇵🇬"),
        Country(key: "py", nameEn: "Paraguay", nameAr: "باراغواي", dialCode: "+595", flag: "🇵🇾"),
        Country(key: "pe", nameEn: "Peru", nameAr: "بيرو", dialCode: "+51", flag: "🇵🇪"),
        Country(key: "ph", nameEn: "Philippines", nameAr: "الفلبين", dialCode: "+63", flag: "🇵🇭"),
        Country(key: "pl", nameEn: "Poland", nameAr: "بولندا", dialCode: "+48", flag: "🇵🇱"),
        Country(key: "pt", nameEn: "Portugal", nameAr: "البرتغال", dialCode: "+351", flag: "🇵🇹"),
        Country(key: "qa", nameEn: "Qatar", nameAr: "قطر", dialCode: "+974", flag: "🇶🇦"),
        Country(key: "ro", nameEn: "Romania", nameAr: "رومانيا", dialCode: "+40", flag: "🇷🇴"),
        Country(key: "ru", nameEn: "Russia", nameAr: "روسيا", dialCode: "+7", flag: "🇷🇺"),
        Country(key: "rw", nameEn: "Rwanda", nameAr: "رواندا", dialCode: "+250", flag: "🇷🇼"),
        Country(key: "kn", nameEn: "Saint Kitts and Nevis", nameAr: "سانت كيتس ونيفيس", dialCode: "+1-869", flag: "🇰🇳"),
        Country(key: "lc", nameEn: "Saint Lucia", nameAr: "سانت لوسيا", dialCode: "+1-758", flag: "🇱🇨"),
        Country(key: "vc", nameEn: "Saint Vincent and the Grenadines", nameAr: "سانت فنسنت وجزر غرينادين", dialCode: "+1-784", flag: "🇻🇨"),
        Country(key: "ws", nameEn: "Samoa", nameAr: "ساموا", dialCode: "+685", flag: "🇼🇸"),
        Country(key: "sm", nameEn: "San Marino", nameAr: "سان مارينو", dialCode: "+378", flag: "🇸🇲"),
        Country(key: "st", nameEn: "São Tomé and Príncipe", nameAr: "ساو تومي وبرينسيبي", dialCode: "+239", flag: "🇸🇹"),
        Country(key: "sa", nameEn: "Saudi Arabia", nameAr: "المملكة العربية السعودية", dialCode: "+966", flag: "🇸🇦"),
        Country(key: "sn", nameEn: "Senegal", nameAr: "السنغال", dialCode: "+221", flag: "🇸🇳"),
        Country(key: "rs", nameEn: "Serbia", nameAr: "صربيا", dialCode: "+381", flag: "🇷🇸"),
        Country(key: "sc", nameEn: "Seychelles", nameAr: "سيشل", dialCode: "+248", flag: "🇸🇨"),
        Country(key: "sl", nameEn: "Sierra Leone", nameAr: "سيراليون", dialCode: "+232", flag: "🇸🇱"),
        Country(key: "sg", nameEn: "Singapore", nameAr: "سنغافورة", dialCode: "+65", flag: "🇸🇬"),
        Country(key: "sk", nameEn: "Slovakia", nameAr: "سلوفاكيا", dialCode: "+421", flag: "🇸🇰"),
        Country(key: "si", nameEn: "Slovenia", nameAr: "سلوفينيا", dialCode: "+386", flag: "🇸🇮"),
        Country(key: "sb", nameEn: "Solomon Islands", nameAr: "جزر سليمان", dialCode: "+677", flag: "🇸🇧"),
        Country(key: "so", nameEn: "Somalia", nameAr: "الصومال", dialCode: "+252", flag: "🇸🇴"),
        Country(key: "za", nameEn: "South Africa", nameAr: "جنوب أفريقيا", dialCode: "+27", flag: "🇿🇦"),
        Country(key: "ss", nameEn: "South Sudan", nameAr: "جنوب السودان", dialCode: "+211", flag: "🇸🇸"),
        Country(key: "es", nameEn: "Spain", nameAr: "إسبانيا", dialCode: "+34", flag: "🇪🇸"),
        Country(key: "lk", nameEn: "Sri Lanka", nameAr: "سريلانكا", dialCode: "+94", flag: "🇱🇰"),
        Country(key: "sd", nameEn: "Sudan", nameAr: "السودان", dialCode: "+249", flag: "🇸🇩"),
        Country(key: "sr", nameEn: "Suriname", nameAr: "سورينام", dialCode: "+597", flag: "🇸🇷"),
        Country(key: "se", nameEn: "Sweden", nameAr: "السويد", dialCode: "+46", flag: "🇸🇪"),
        Country(key: "ch", nameEn: "Switzerland", nameAr: "سويسرا", dialCode: "+41", flag: "🇨🇭"),
        Country(key: "sy", nameEn: "Syria", nameAr: "سوريا", dialCode: "+963", flag: "🇸🇾"),
        Country(key: "tw", nameEn: "Taiwan", nameAr: "تايوان", dialCode: "+886", flag: "🇹🇼"),
        Country(key: "tj", nameEn: "Tajikistan", nameAr: "طاجيكستان", dialCode: "+992", flag: "🇹🇯"),
        Country(key: "tz", nameEn: "Tanzania", nameAr: "تنزانيا", dialCode: "+255", flag: "🇹🇿"),
        Country(key: "th", nameEn: "Thailand", nameAr: "تايلاند", dialCode: "+66", flag: "🇹🇭"),
        Country(key: "tl", nameEn: "Timor-Leste", nameAr: "تيمور الشرقية", dialCode: "+670", flag: "🇹🇱"),
        Country(key: "tg", nameEn: "Togo", nameAr: "توغو", dialCode: "+228", flag: "🇹🇬"),
        Country(key: "to", nameEn: "Tonga", nameAr: "تونغا", dialCode: "+676", flag: "🇹🇴"),
        Country(key: "tt", nameEn: "Trinidad and Tobago", nameAr: "ترينيداد وتوباغو", dialCode: "+1-868", flag: "🇹🇹"),
        Country(key: "tn", nameEn: "Tunisia", nameAr: "تونس", dialCode: "+216", flag: "🇹🇳"),
        Country(key: "tr", nameEn: "Turkey", nameAr: "تركيا", dialCode: "+90", flag: "🇹🇷"),
        Country(key: "tm", nameEn: "Turkmenistan", nameAr: "تركمانستان", dialCode: "+993", flag: "🇹🇲"),
        Country(key: "tv", nameEn: "Tuvalu", nameAr: "توفالو", dialCode: "+688", flag: "🇹🇻"),
        Country(key: "ug", nameEn: "Uganda", nameAr: "أوغندا", dialCode: "+256", flag: "🇺🇬"),
        Country(key: "ua", nameEn: "Ukraine", nameAr: "أوكرانيا", dialCode: "+380", flag: "🇺🇦"),
        Country(key: "ae", nameEn: "United Arab Emirates", nameAr: "الإمارات العربية المتحدة", dialCode: "+971", flag: "🇦🇪"),
        Country(key: "gb", nameEn: "United Kingdom", nameAr: "المملكة المتحدة", dialCode: "+44", flag: "🇬🇧"),
        Country(key: "us", nameEn: "United States", nameAr: "الولايات المتحدة", dialCode: "+1", flag: "🇺🇸"),
        Country(key: "uy", nameEn: "Uruguay", nameAr: "أوروغواي", dialCode: "+598", flag: "🇺🇾"),
        Country(key: "uz", nameEn: "Uzbekistan", nameAr: "أوزبكستان", dialCode: "+998", flag: "🇺🇿"),
        Country(key: "vu", nameEn: "Vanuatu", nameAr: "فانواتو", dialCode: "+678", flag: "🇻🇺"),
        Country(key: "va", nameEn: "Vatican City", nameAr: "الفاتيكان", dialCode: "+379", flag: "🇻🇦"),
        Country(key: "ve", nameEn: "Venezuela", nameAr: "فنزويلا", dialCode: "+58", flag: "🇻🇪"),
        Country(key: "vn", nameEn: "Vietnam", nameAr: "فيتنام", dialCode: "+84", flag: "🇻🇳"),
        Country(key: "ye", nameEn: "Yemen", nameAr: "اليمن", dialCode: "+967", flag: "🇾🇪"),
        Country(key: "zm", nameEn: "Zambia", nameAr: "زامبيا", dialCode: "+260", flag: "🇿🇲"),
        Country(key: "zw", nameEn: "Zimbabwe", nameAr: "زيمبابوي", dialCode: "+263", flag: "🇿🇼"),
    ]
}

struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: isSelected ? 28 : 22))
                
                Text(Localizer.shared.language == .arabic ? country.nameAr : country.nameEn)
                    .font(.system(size: isSelected ? 17 : 15, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .appText.opacity(0.75))
                    .lineLimit(1)
                
                Spacer()
                
                radioIndicator
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isSelected ? 16 : 11)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "F0A818") : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var radioIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.appText.opacity(isSelected ? 0 : 0.55), lineWidth: 1.5)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .fill(Color.green)
                    .frame(width: 22, height: 22)
            }
        }
    }
    
    @ViewBuilder
    private var rowBackground: some View {
        if isSelected {
            Color(hex: "6030A0").opacity(0.85)
        } else {
            Color.appText.opacity(0.12)
        }
    }
}
