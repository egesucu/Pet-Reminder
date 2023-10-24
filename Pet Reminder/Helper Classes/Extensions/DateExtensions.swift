//
//  DateExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

extension Date {
    static let tomorrow: Date = {
        var today = Calendar.current.startOfDay(for: Date.now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        return tomorrow
    }()

    /// 08:00 AM of the current day
    static let eightAM: Self = {
        return Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*8)
    }()

    /// 08:00 PM of the current day
    static let eightPM: Self = {
        return Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*20)
    }()

    func convertDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.string(from: self)
    }
    func convertStringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.date(from: string) ?? Date()
    }

    func printTime() -> String {
        return self.formatted(.dateTime.hour().minute())
    }

    func printDate() -> String {
        return self.formatted(.dateTime.day()
            .month(.twoDigits).year())
    }

    static func randomDate() -> Self {
        let components: DateComponents = .generateRandomDateComponent()
        return Calendar.current.date(from: components) ?? .now
    }
}
// MARK: - Calendar
extension Calendar {
    func isDateLater(date: Date) -> Bool {
        return date >= Date.tomorrow
    }
}

/// 60(sec) * 60(min) * 24(hours) * 30(days) = 2_592_000
let oneMonthInMilliSeconds: Double = 2_592_000
