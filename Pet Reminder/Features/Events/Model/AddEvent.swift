//
//  AddEvent.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 7.03.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI

@Observable
@MainActor
class AddEvent {
    var eventTitle = ""
    var dateString = ""
    var isShowing = false
    var showWarningForCalendar = false
}
