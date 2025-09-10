//
//  EventFilterMenu.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 17.05.2025.
//  Copyright © 2025 Ege Sucu. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import EventKit
import Shared

struct EventFilterMenu: ToolbarContent {

    @Environment(EventManager.self) private var manager

    func iconNameDefinition(_ title: String) -> String {
        title.prefix(1).localizedLowercase
    }

    var allCalendars: [EventCalendar] {
        let allOption = EventCalendar(String(localized: .all))
        return ([allOption] + manager.calendars)
    }

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                ForEach(allCalendars, id: \.title) { calendar in
                    Button {
                        if calendar.title == String(localized: .all) {
                            manager.selectedCalendar = nil
                        } else {
                            manager.selectedCalendar = calendar
                        }
                    } label: {
                        HStack {
                            Image(systemName: "\(iconNameDefinition(calendar.title)).circle.fill")
                                .symbolRenderingMode(.monochrome)
                                .overlay(
                                    Group {
                                        if manager.selectedCalendar == calendar {
                                            Image(systemSymbol: .checkmark)
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    },
                                    alignment: .center
                                )

                            Text(calendar.title)
                                .fontWeight(manager.selectedCalendar == calendar ? .semibold : .regular)
                        }
                    }
                    .tag(calendar)
                }
            } label: {
                Image(systemSymbol: .ellipsis)
                    .foregroundStyle(Color.accent)
            }
            .menuOrder(.priority)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack {
                Text(.hello)
            }
            .navigationTitle(Text(.hello))
            .toolbar {
                EventFilterMenu()
            }
        }
    }
    .environment(EventManager.demo)

}
