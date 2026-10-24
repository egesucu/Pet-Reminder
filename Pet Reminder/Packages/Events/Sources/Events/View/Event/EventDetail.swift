import EventKit
import Shared
import SwiftUI

/// A lightweight summary of the event already loaded by the agenda.
struct EventDetail: View {
    @Environment(EventManager.self) private var manager
    let event: EKEvent
    var onComplete: () -> Void = {}
    @State private var showEditor = false
    @State private var editingEvent: EKEvent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.title ?? "")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                    Label(EventDetailFormatting.dateDescription(event), systemImage: "calendar")
                    Label(EventDetailFormatting.timeDescription(event), systemImage: "clock")
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)

                Divider()

                detailSection(SharedStrings.resource("Calendar"), symbol: "calendar") {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(event.calendar.cgColor.map { Color(cgColor: $0) } ?? .accentColor)
                            .accessibilityHidden(true)
                        Text(event.calendar.title)
                    }
                }

                if let rules = event.recurrenceRules, !rules.isEmpty {
                    detailSection(SharedStrings.resource("Repeat"), symbol: "repeat") {
                        ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                            Text(EventDetailFormatting.recurrenceDescription(rule))
                            if let end = rule.recurrenceEnd {
                                if let endDate = end.endDate {
                                    Text(String(localized: SharedStrings.resource("Ends \(endDate.formatted(date: .abbreviated, time: .omitted))")))
                                        .foregroundStyle(.secondary)
                                } else if end.occurrenceCount > 0 {
                                    Text(SharedStrings.resource("After \(Int64(end.occurrenceCount)) occurrences"))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                if let alarms = event.alarms, !alarms.isEmpty {
                    detailSection(SharedStrings.resource("Reminder"), symbol: "bell") {
                        ForEach(Array(alarms.enumerated()), id: \.offset) { _, alarm in
                            Text(EventDetailFormatting.alarmDescription(alarm))
                        }
                    }
                }

                if let location = event.location, !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    detailSection(SharedStrings.resource("Location"), symbol: "mappin.and.ellipse") {
                        Text(location).textSelection(.enabled)
                    }
                }
                if let notes = event.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    detailSection(SharedStrings.resource("Notes"), symbol: "note.text") {
                        Text(notes).textSelection(.enabled)
                    }
                }
                if let url = event.url {
                    detailSection(SharedStrings.resource("Website"), symbol: "link") {
                        Link(url.absoluteString, destination: url)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if event.calendar.allowsContentModifications, manager.eventStore is EKEventStore {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingEvent = event
                        showEditor = true
                    } label: {
                        Text(SharedStrings.resource("Edit"))
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: onComplete) {
            if let editingEvent, let store = manager.eventStore as? EKEventStore {
                EventEditor(event: editingEvent, eventStore: store) {
                    showEditor = false
                }
                .interactiveDismissDisabled()
            }
        }
    }

    private func detailSection<Content: View>(
        _ title: LocalizedStringResource,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}
