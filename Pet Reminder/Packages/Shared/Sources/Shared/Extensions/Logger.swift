//
//  Logger.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import OSLog

extension Logger {
    public static let subsystem = Bundle.main.bundleIdentifier!

    public static let events = Logger(subsystem: subsystem, category: "Event")

    public static let vet = Logger(subsystem: subsystem, category: "Find Vet")

    public static let pets = Logger(subsystem: subsystem, category: "Pet")

    public static let feed = Logger(subsystem: subsystem, category: "Feed")

    public static let settings = Logger(subsystem: subsystem, category: "Settings")

    public static let notifications = Logger(subsystem: subsystem, category: "Notifications")

}
