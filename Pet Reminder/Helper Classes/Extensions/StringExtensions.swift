//
//  StringExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import EventKit
import Foundation
import SwiftUI

// MARK: - Strings

enum Strings {
  static let demoPets = [
    "Viski", "Dolly", "Mısır", "Boncuk",
    "Pop", "Rocky", "Bunny", "Spur", "Lully",
    "Baggy",
  ]
  static let demoVaccines = ["Pulvarin", "Alvarin", "Gagarin", "Aclor", "Silverin", "Volverine"]
  static let placeholderVaccine = "Pulvarin"
  static let demo = "Demo"
  static let petSaved = "petSaved"
  static let tintColor = "tint_color"
  static let doggo = "Doggo"
  static let viski = "Viski"
  static let donateTeaID = "pet_reminder_tea_donate"
  static let donateFoodID = "pet_reminder_food_donate"
  static let helloSeen = "seenHello"

  static let demoDataOccured = "demoDataOccured"
  static let petReminder = "Pet Reminder"

  static func footerLabel(_ first: Any) -> String {
    "© Ege Sucu \(first)"
  }

  static func notificationIdenfier(_ first: Any, _ second: Any) -> String {
    "\(first)-\(second)-notification"
  }

  static func demoEvent(_ first: Any) -> String {
    "Demo Event \(first)"
  }

}

extension String {
  var isNotEmpty: Bool {
    !isEmpty
  }

  static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
    if allDay {
      current
        ? String(
          localized: "all_day_title")
        : String.futureDateTimeFormat(
          allDay: allDay,
          event: event)
    } else {
      current
        ? String.currentDateTimeFormat(
          allDay: allDay,
          event: event)
        : String.futureDateTimeFormat(
          allDay: allDay,
          event: event)
    }
  }

  static func futureDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
    if allDay {
      "\(event.startDate.printDate()) \(String(localized: "all_day_title"))"
    } else {
      "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
    }
  }

  static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
    if allDay {
      String(localized: "all_day_title")
    } else {
      "\(event.startDate.printTime()) - \(event.endDate.printTime())"
    }
  }

}

extension LocalizedStringKey {
  static let save: Self = "save"
  static let cancel: Self = "cancel"
}
