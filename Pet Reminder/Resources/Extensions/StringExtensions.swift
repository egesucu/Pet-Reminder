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

struct Strings {
    static let demoPets = [
        "Viski", "Dolly", "Mısır", "Boncuk",
        "Pop", "Rocky", "Bunny", "Spur", "Lully",
        "Baggy"
    ]
    static let demoVaccines = ["Pulvarin", "Alvarin", "Gagarin", "Aclor", "Silverin", "Volverine"]
    static let placeholderVaccine = "Pulvarin"
    static let demo = "Demo"
    static let petSaved = "petSaved"
    static let doggo = "Doggo"
    static let viski = "Viski"
    static let donateTeaID = "pet_reminder_tea_donate"
    static let donateFoodID = "pet_reminder_food_donate"
    static let helloSeen = "seenHello"

    static func footerLabel(_ first: Any) -> String {
        return "© Ege Sucu \(first)"
    }
    static func notificationIdenfier(_ first: Any, _ second: Any) -> String {
      return "\(first)-\(second)-notification"
    }

    static func demoEvent(_ first: Any) -> String {
        return "Demo Event \(first)"
    }

    static let demoDataOccured = "demoDataOccured"
    static let petReminder = "Pet Reminder"

}

extension String {
    static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return current ? String(
                localized: "all_day_title"
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
            return "\(event.startDate.printDate()) \(String(localized: "all_day_title"))"
        } else {
            return "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return String(localized: "all_day_title")
        } else {
            return "\(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension LocalizedStringKey {
    @MainActor static let save: Self = "save"
    @MainActor static let cancel: Self = "cancel"
}
