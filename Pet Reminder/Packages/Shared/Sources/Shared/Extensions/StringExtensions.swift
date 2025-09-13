//
//  StringExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

public struct Strings {
    public static let demoPets = [
        "Viski", "Dolly", "Mısır", "Boncuk",
        "Pop", "Rocky", "Bunny", "Spur", "Lully",
        "Baggy"
    ]
    public static let demoVaccines = ["Pulvarin", "Alvarin", "Gagarin", "Aclor", "Silverin", "Volverine"]
    public static let placeholderVaccine = "Pulvarin"
    public static let demo = "Demo"
    public static let petSaved = "petSaved"
    public static let doggo = "Doggo"
    public static let viski = "Viski"
    public static let donateTeaID = "pet_reminder_tea_donate"
    public static let donateFoodID = "pet_reminder_food_donate"
    public static let helloSeen = "seenHello"

    public static func footerLabel(_ first: Any) -> String {
        return "© Ege Sucu \(first)"
    }
    public static func notificationIdenfier(_ first: Any, _ second: Any) -> String {
      return "\(first)-\(second)-notification"
    }

    public static func demoEvent(_ first: Any) -> String {
        return "Demo Event \(first)"
    }

    public static let demoDataOccured = "demoDataOccured"
    public static let petReminder = "Pet Reminder"

}

public extension String {
    static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return current ? String(
                localized: .allDayTitle
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        } else {
            return current ? String.currentDateTimeFormat(
                allDay: allDay,
                event: event
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        }
    }

    func convertStringToDate(locale: Locale = .current) -> Date {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: self) ?? Date()
    }

    static func futureDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return "\(event.startDate.printDate()) \(String(localized: .allDayTitle))"
        } else {
            return "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return String(localized: .allDayTitle)
        } else {
            return "\(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }
}
