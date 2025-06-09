//
//  DateExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public extension Date {
    static let tomorrow: Date = {
        var today = Calendar.current.startOfDay(for: .now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? .now
        return tomorrow
    }()

    /// 08:00 AM of the current day
    static let eightAM: Self = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return calendar.date(byAdding: .hour, value: 8, to: today) ?? .now
    }()

    /// 08:00 PM of the current day
    static let eightPM: Self = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return calendar.date(byAdding: .hour, value: 20, to: today) ?? .now
    }()

    func printTime(locale: Locale = .current) -> String {
        return self.formatted(.dateTime.hour().minute().locale(locale))
    }

    func printDate(locale: Locale = .current) -> String {
        return self.formatted(.dateTime.day()
            .month(.twoDigits).year().locale(locale))
    }

    static func randomDate() -> Self {
        let components: DateComponents = .generateRandomDateComponent()
        return Calendar.current.date(from: components) ?? .now
    }
}
// MARK: - Calendar
public extension Calendar {
    func isDateLater(date: Date) -> Bool {
        return date >= Date.tomorrow
    }
}

// MARK: - DateComponents
public extension DateComponents {
    static func generateRandomDateComponent() -> Self {
        let components = Calendar.current.dateComponents([.year], from: .now)
        let currentYear = components.year ?? 2020
        return DateComponents(
            year: Int.random(in: 2014...currentYear),
            month: Int.random(in: 0...12),
            day: Int.random(in: 0...30),
            hour: Int.random(in: 0...23),
            minute: Int.random(in: 0...59),
            second: Int.random(in: 0...59)
        )
    }
}
