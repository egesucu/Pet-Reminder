import Foundation
import EventKit
import Shared

extension String {
    static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return current ? String(
                localized: SharedStrings.allDayTitle
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        } else {
            return current ? String.currentDateTimeFormat(
                allDay: allDay,
                event: event
            ) : String.futureDateTimeFormat(
                allDay: allDay,
                event: event
            )
        }
    }

    static func futureDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return "\(event.startDate.printDate()) \(String(localized: SharedStrings.allDayTitle))"
        } else {
            return "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

    static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return String(localized: SharedStrings.allDayTitle)
        } else {
            return "\(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }

}
