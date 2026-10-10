import SwiftUI
import EventKit
import Shared

struct SingleEvent: View {
    var event: EKEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title ?? "").font(.headline).foregroundStyle(.primary)
            Text(timeDescription).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(event.calendar.cgColor.map { Color(cgColor: $0) } ?? .accentColor)
                    .accessibilityHidden(true)
                Text(event.calendar.title).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var timeDescription: String {
        if event.isAllDay { return String(localized: SharedStrings.allDayTitle) }
        let sameDay = Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate)
        let start = event.startDate.formatted(date: sameDay ? .omitted : .abbreviated, time: .shortened)
        let end = event.endDate.formatted(date: sameDay ? .omitted : .abbreviated, time: .shortened)
        return "\(start) – \(end)"
    }
}
