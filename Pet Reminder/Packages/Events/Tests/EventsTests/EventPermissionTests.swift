import EventKit
import Foundation
import Testing
@testable import Events

/// Rejects any store access other than an explicit permission request. No
/// EKEventStore is constructed, and no device calendars or accounts are used.
private final class PermissionStore: EventStoreProtocol, @unchecked Sendable {
    let granted: Bool
    let fails: Bool
    private(set) var requests = 0
    init(granted: Bool = false, fails: Bool = false) { self.granted = granted; self.fails = fails }
    func requestFullAccessToEvents() async throws -> Bool {
        requests += 1
        if fails { throw NSError(domain: "PermissionFixture", code: 1) }
        return granted
    }
    func calendars(for entityType: EKEntityType) -> [EKCalendar] { preconditionFailure("Unauthorized calendar read") }
    var defaultCalendarForNewEvents: EKCalendar? { preconditionFailure("Unauthorized calendar read") }
    func predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate { preconditionFailure("Unauthorized query") }
    func events(matching: NSPredicate) -> [EKEvent] { preconditionFailure("Unauthorized query") }
    func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws { preconditionFailure("Unauthorized save") }
    func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws { preconditionFailure("Unauthorized save") }
    func makeCalendar(for entityType: EKEntityType) -> EKCalendar { preconditionFailure("Unauthorized creation") }
    func makeEvent() -> EKEvent { preconditionFailure("Unauthorized creation") }
}

@MainActor
@Suite("Permission isolation")
struct EventPermissionTests {
    @Test("Denied, restricted and write-only statuses never access device calendars",
          arguments: [EKAuthorizationStatus.denied, .restricted, .writeOnly])
    func inaccessible(_ status: EKAuthorizationStatus) async {
        let suite = "EventsPermissionTests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let store = PermissionStore()
        let sut = EventManager(eventStore: store, now: { Date(timeIntervalSince1970: 1_000_000) }, preferences: preferences, authorizationStatusProvider: { status })
        await sut.reloadEvents()
        #expect(store.requests == 0)
        #expect(sut.status == (status == .writeOnly ? .readOnly : .denied))
        #expect(sut.events.isEmpty && sut.calendars.isEmpty && sut.petCalendar == nil)
    }

    @Test("Selection writes identifiers and All to isolated preferences")
    func preferenceWrites() {
        let suite = "EventsPermissionTests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let sut = EventManager(eventStore: PermissionStore(), preferences: preferences)
        let first = EventCalendar(id: "personal-1", title: "Personal")
        let second = EventCalendar(id: "personal-2", title: "Personal")
        sut.selectedCalendar = first
        #expect(preferences.string(forKey: "events.selectedCalendar") == "personal-1")
        sut.selectedCalendar = second
        #expect(preferences.string(forKey: "events.selectedCalendar") == "personal-2")
        let rules = AgendaRules(now: Date(timeIntervalSince1970: 1_000_000), calendar: Calendar(identifier: .gregorian))
        #expect(rules.selectedCalendarID(saved: preferences.string(forKey: "events.selectedCalendar"), available: [first.id, second.id], petID: nil) == second.id)
        sut.selectedCalendar = nil
        #expect(preferences.string(forKey: "events.selectedCalendar") == AgendaRules.allCalendarsID)
    }

    @Test("Permission denial and errors leave the agenda empty", arguments: [false, true])
    func requestFailure(_ fails: Bool) async {
        let suite = "EventsPermissionTests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName: suite)!
        defer { preferences.removePersistentDomain(forName: suite) }
        let store = PermissionStore(fails: fails)
        let sut = EventManager(eventStore: store, preferences: preferences, authorizationStatusProvider: { .notDetermined })
        await sut.reloadEvents()
        #expect(store.requests == 1)
        #expect(sut.events.isEmpty && sut.calendars.isEmpty)
        #expect(sut.status == (fails ? .notDetermined : .denied))
    }
}
