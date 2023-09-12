//
//  Logger.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")

    static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
