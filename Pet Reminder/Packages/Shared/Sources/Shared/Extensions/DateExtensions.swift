//
//  DateExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

extension Date {
    public static let tomorrow: Date = {
        var today = Calendar.current.startOfDay(for: Date.now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        return tomorrow
    }()

    /// 08:00 AM of the current day
    public static let eightAM: Self = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .hour, value: 8, to: today) ?? .now
    }()

    /// 08:00 PM of the current day
    public static let eightPM: Self = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .hour, value: 20, to: today) ?? .now
    }()

    public func printTime(locale: Locale = .current) -> String {
        return self.formatted(.dateTime.hour().minute().locale(locale))
    }

    public func printDate(locale: Locale = .current) -> String {
        return self.formatted(.dateTime.day()
            .month(.twoDigits).year().locale(locale))
    }

    public static func randomDate() -> Self {
        let components: DateComponents = .generateRandomDateComponent()
        return Calendar.current.date(from: components) ?? .now
    }
}
// MARK: - Calendar
extension Calendar {
    public func isDateLater(date: Date) -> Bool {
        return date >= Date.tomorrow
    }
}

// MARK: - DateComponents
extension DateComponents {
    public static func generateRandomDateComponent() -> Self {
        DateComponents(
            year: Int.random(in: 2018...2023),
            month: Int.random(in: 0...12),
            day: Int.random(in: 0...30),
            hour: Int.random(in: 0...23),
            minute: Int.random(in: 0...59),
            second: Int.random(in: 0...59)
        )
    }
}
