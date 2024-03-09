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
    private static var subsystem: String { Bundle.main.bundleIdentifier! }
    
    static var events : Logger {
        Logger(subsystem: subsystem, category: "Event")
    }
    
    static var vet: Logger {
        Logger(subsystem: subsystem, category: "Find Vet")
    }
    
    static var pets: Logger {
        Logger(subsystem: subsystem, category: "Pet")
    }
    
    static var feed: Logger {
        Logger(subsystem: subsystem, category: "Feed")
    }
    
    static var settings: Logger {
        Logger(subsystem: subsystem, category: "Settings")
    }
    
    static var notifications: Logger {
        Logger(subsystem: subsystem, category: "Notifications")
    }
}
