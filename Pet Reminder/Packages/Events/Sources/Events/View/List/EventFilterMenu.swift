//
//  EventFilterMenu.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 17.05.2025.
//  Copyright © 2025 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared
import SharedUI

struct EventFilterMenu: ToolbarContent {

    @Environment(EventManager.self) private var manager

    var allCalendars: [EventCalendar] {
        let allOption = EventCalendar(String(localized: SharedStrings.all))
        return ([allOption] + manager.calendars)
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                ForEach(allCalendars) { calendar in
                    Button {
                        if calendar.title == String(localized: SharedStrings.all) {
                            manager.selectedCalendar = nil
                        } else {
                            manager.selectedCalendar = calendar
                        }
                    } label: {
                        Text(calendar.title)
                            .fontWeight(manager.selectedCalendar == calendar ? .semibold : .regular)
                    }
                    .tag(calendar.title)
                }
            } label: {
                Text(manager.selectedCalendar?.title ?? String(localized: SharedStrings.all))
            }
            .menuOrder(.priority)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ScrollView {
            VStack {
                Text(SharedStrings.hello)
            }
            .navigationTitle(Text(SharedStrings.hello))
            .toolbar {
                EventFilterMenu()
            }
        }
    }
    .environment(EventManager.demo)

}
#endif
