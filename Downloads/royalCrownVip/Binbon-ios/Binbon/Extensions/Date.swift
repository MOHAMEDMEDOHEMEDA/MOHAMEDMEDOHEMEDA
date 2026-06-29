//
//  Date.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import Foundation

extension Date {


    func display(_ format: String, localized: Bool = true, timeZone: TimeZone? = nil) -> String {
        let locale = localized
            ? Locale(identifier: Storage.shared.language)
            : Locale(identifier: "en_US_POSIX")
        return DateFormatterCache.formatter(format: format, locale: locale, timeZone: timeZone).string(from: self)
    }

    /// `"yyyy-MM-dd"` in a fixed locale — for request payloads.
    var apiDateString: String { display("yyyy-MM-dd", localized: false) }

   
    var apiScheduledFor: String {
        display("yyyy-MM-dd'T'HH:mm:ss", localized: false, timeZone: TimeZone(identifier: "UTC")) + "+00:00"
    }

    /// Parses an ISO-8601 string, with or without fractional seconds.
    static func from(iso string: String) -> Date? {
        DateFormatterCache.iso.date(from: string)
            ?? DateFormatterCache.isoFractional.date(from: string)
    }
}

/// Caches `DateFormatter`s by (locale, timezone, format) so we don't allocate one per call.
private enum DateFormatterCache {

    static let iso = ISO8601DateFormatter()

    static let isoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static var cache: [String: DateFormatter] = [:]
    private static let lock = NSLock()

    static func formatter(format: String, locale: Locale, timeZone: TimeZone?) -> DateFormatter {
        let key = "\(locale.identifier)|\(timeZone?.identifier ?? "")|\(format)"
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[key] { return cached }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
        if let timeZone { formatter.timeZone = timeZone }
        cache[key] = formatter
        return formatter
    }
}
