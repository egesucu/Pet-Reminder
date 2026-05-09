//
//  Event.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 7.03.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import Shared
import SwiftUI

@Observable
@MainActor
class Event {
    var eventTitle = String.empty
    var dateString = String.empty
    var isShowing = false
    var showWarningForCalendar = false
}
