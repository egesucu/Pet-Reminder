//
//  StringExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

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
    public static let donateCoffeeID = "pet_reminder_coffee_donate"
    public static let donateToyID = "pet_reminder_toy_donate"
    public static let donateFeastID = "pet_reminder_feast_donate"
    public static let helloSeen = "seenHello"

    public static func footerLabel(_ first: Any) -> String {
        return "© Ege Sucu \(first)"
    }

    // Renamed from `notificationIdenfier` to `notificationIdentifier`
    public static func notificationIdentifier(_ first: Any, _ second: Any) -> String {
        return "\(first)-\(second)-notification"
    }

    public static func demoEvent(_ first: Any) -> String {
        return "Demo Event \(first)"
    }

    public static let demoDataOccured = "demoDataOccured"
    public static let petReminder = "Pet Reminder"
}

public extension String {
    func convertStringToDate(locale: Locale = .current) -> Date {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: self) ?? Date()
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }

    static let empty = ""
}
