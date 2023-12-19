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

  // MARK: Internal

  static let events = Logger(subsystem: subsystem, category: "Event")

  static let vet = Logger(subsystem: subsystem, category: "Find Vet")

  static let pets = Logger(subsystem: subsystem, category: "Pet")

  static let feed = Logger(subsystem: subsystem, category: "Feed")

  static let settings = Logger(subsystem: subsystem, category: "Settings")

  static let notifications = Logger(subsystem: subsystem, category: "Notifications")

  // MARK: Private

  private static var subsystem = Bundle.main.bundleIdentifier!
}
